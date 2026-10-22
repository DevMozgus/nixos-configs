/**
 * peon-ping for OpenCode — event bridge
 *
 * Routes OpenCode events through peon.sh instead of re-implementing
 * sound playback, notifications, and trainer features in TypeScript.
 *
 * This gives OpenCode users access to ALL peon-ping features:
 * - Sound packs & rotation
 * - Desktop notifications
 * - Trainer reminders (pushups, squats, etc.)
 * - Spam detection
 * - SSH/devcontainer relay
 * - All config options via `peon` CLI
 * - Tab title updates
 *
 * Requires peon-ping installed: brew install PeonPing/tap/peon-ping
 *   or: curl -fsSL peonping.com/install | bash
 *
 * ---------------------------------------------------------------------------
 * LOCAL PATCH (nixos-configs):
 * Based on upstream PeonPing/peon-ping adapters/opencode/peon-ping.ts
 * @ rev de4ada79a43dbf19a58cb403dc242113d0b60446, which only implements the
 * OpenCode 2.x plugin API (`setup`). OpenCode 1.x (e.g. 1.18.35) uses the V1
 * loader that requires a `server()` export and rejects `setup`-only modules
 * ("must default export an object with server()").
 *
 * This file is a union adapter: `server` serves OpenCode 1.x, `setup` serves
 * OpenCode 2.x (kept verbatim from upstream for easy future diffing).
 * REVERT to the upstream store path in peon-ping.nix once upstream ships a
 * union export.
 * ---------------------------------------------------------------------------
 */

import * as fs from "node:fs"
import * as path from "node:path"
import * as os from "node:os"
import { spawn } from "node:child_process"

const MAX_PENDING_QUESTION_IDS = 100
const LOCATION_OWNERS = Symbol.for("peon-ping.opencode.location-owners")
const SCOPED_EVENT_TYPES = new Set([
  "session.created", "session.deleted", "session.execution.started",
  "session.execution.succeeded", "session.execution.failed", "session.execution.interrupted",
  "permission.asked", "form.created", "form.replied", "form.cancelled",
])

function findPeonScript(windows: boolean): string | null {
  const filename = windows ? "peon.ps1" : "peon.sh"
  const directories = [
    process.env.CLAUDE_PEON_DIR,
    path.join(process.env.CLAUDE_CONFIG_DIR || path.join(os.homedir(), ".claude"), "hooks", "peon-ping"),
    path.join(os.homedir(), ".openpeon", "hooks", "peon-ping"),
    path.join(os.homedir(), ".openpeon"),
    path.join(os.homedir(), ".openclaw", "hooks", "peon-ping"),
  ]
  for (const directory of directories) {
    if (!directory) continue
    const candidate = path.join(directory, filename)
    try {
      if (fs.existsSync(candidate)) return candidate
    } catch {}
  }
  return null
}

function setTabTitle(title: string): void {
  if (!process.stdout.isTTY) return
  process.stdout.write(`\x1b]0;${title}\x07`)
}

function warnNotInstalled(windows: boolean): void {
  console.warn(`[peon-ping] ${windows ? "peon.ps1" : "peon.sh"} not found. Install peon-ping first:`)
  if (windows) {
    console.warn("  https://github.com/PeonPing/peon-ping#option-3-installer-for-windows")
  } else {
    console.warn("  brew install PeonPing/tap/peon-ping")
    console.warn("  # or: curl -fsSL peonping.com/install | bash")
  }
}

/**
 * OpenCode v2 payloads carry the event body under `data`. Only the fields this
 * adapter reads are typed; the rest of the union is intentionally open.
 */
type V2Event = {
  id?: string
  type: string
  data?: Record<string, any>
  location?: { directory?: string }
}

export default {
  id: "peon-ping",

  /**
   * OpenCode 1.x entry point (V1 plugin API, e.g. opencode 1.18.35).
   *
   * The host loads `server(input)` and calls the returned `event` hook for
   * every bus event in this plugin's directory — payload arrives as
   * `{ id, type, properties }` (v1 shape). Shutdown goes through `dispose`.
   *
   * v1 → peon hook mapping (see docs/opencode-v2-events.md upstream):
   *   SessionStart        ← first session.status(busy) of a session
   *   UserPromptSubmit    ← session.status(busy), debounced 3s after start
   *   Stop                ← session.status(idle) / deprecated session.idle
   *   PostToolUseFailure  ← session.error (except MessageAbortedError aborts)
   *   PermissionRequest   ← permission.asked
   *   Notification        ← question.asked (v1 name of form.created)
   */
  server: async (input: any) => {
    const projectName = path.basename(input?.directory || process.cwd()) || "opencode"
    const windows = os.platform() === "win32"
    const peonScript = findPeonScript(windows)

    if (!peonScript) {
      warnNotInstalled(windows)
      return {}
    }

    const cwd = input?.directory || process.cwd()
    const sessionId = `oc-${Date.now()}`
    const subagentSessionIds = new Set<string>()
    const busySessions = new Set<string>()
    const sessionStarts = new Map<string, number>()
    const pendingQuestionIds = new Set<string>()

    function firePeon(event: string, notificationType = ""): void {
      const payload = JSON.stringify({
        hook_event_name: event,
        notification_type: notificationType,
        cwd,
        session_id: sessionId,
        permission_mode: "",
        source: "opencode",
      })

      try {
        const proc = spawn(windows ? "powershell.exe" : "bash", windows
          ? ["-NoProfile", "-NonInteractive", "-File", peonScript!]
          : [peonScript!], {
          stdio: ["pipe", "ignore", "ignore"],
        })
        // Launch failures and early child exits arrive asynchronously, outside
        // this try/catch. Notifications must never take down the plugin host.
        proc.on("error", () => {})
        proc.stdin?.on("error", () => {})
        proc.stdin?.write(payload)
        proc.stdin?.end()
        proc.unref()
      } catch {}
    }

    function isSubagent(sid: unknown): boolean {
      return typeof sid === "string" && subagentSessionIds.has(sid)
    }

    function handleV1(evt: { type?: string; properties?: any }): void {
      const p = evt.properties ?? {}
      const sid = p.sessionID

      switch (evt.type) {
        case "session.created": {
          if (p.info?.parentID && typeof sid === "string") subagentSessionIds.add(sid)
          break
        }

        // v1 publishes turn start as session.status(busy). The first one for a
        // session doubles as SessionStart so the debounce suppresses the
        // UserPromptSubmit that immediately follows (pre-v2 behaviour).
        case "session.status": {
          if (typeof sid !== "string") break
          if (p.status === "busy") {
            if (isSubagent(sid) || busySessions.has(sid)) break
            busySessions.add(sid)
            const lastSessionStart = sessionStarts.get(sid)
            if (lastSessionStart === undefined) {
              sessionStarts.set(sid, Date.now())
              setTabTitle(`${projectName}: ready`)
              firePeon("SessionStart")
            } else if (Date.now() - lastSessionStart > 3000) {
              setTabTitle(`${projectName}: working`)
              firePeon("UserPromptSubmit")
            }
          } else if (p.status === "idle") {
            if (isSubagent(sid)) break
            // Busy-gated so the deprecated session.idle twin (if the host
            // still publishes it) can never double-fire Stop.
            if (!busySessions.has(sid)) break
            busySessions.delete(sid)
            setTabTitle(`\u25cf ${projectName}: done`)
            firePeon("Stop")
          }
          break
        }

        // Deprecated at 1.18.35 but kept for hosts that still publish it.
        case "session.idle": {
          if (typeof sid !== "string" || isSubagent(sid)) break
          if (!busySessions.has(sid)) break
          busySessions.delete(sid)
          setTabTitle(`\u25cf ${projectName}: done`)
          firePeon("Stop")
          break
        }

        case "session.error": {
          if (isSubagent(sid)) break
          if (sid) busySessions.delete(sid)
          // Aborted turns surface as MessageAbortedError — the v1 face of
          // session.execution.interrupted. Silent cleanup, no error sound.
          if (p.error?.name === "MessageAbortedError") break
          setTabTitle(`\u25cf ${projectName}: error`)
          firePeon("PostToolUseFailure")
          break
        }

        case "permission.asked": {
          if (isSubagent(sid)) break
          setTabTitle(`\u25cf ${projectName}: needs approval`)
          firePeon("PermissionRequest")
          break
        }

        case "question.asked": {
          if (isSubagent(sid)) break
          const requestId = p.id
          if (typeof requestId !== "string" || pendingQuestionIds.has(requestId)) break
          if (pendingQuestionIds.size >= MAX_PENDING_QUESTION_IDS) {
            pendingQuestionIds.delete(pendingQuestionIds.values().next().value!)
          }
          pendingQuestionIds.add(requestId)
          setTabTitle(`\u25cf ${projectName}: needs input`)
          firePeon("Notification", "elicitation_dialog")
          break
        }

        case "question.replied":
        case "question.rejected": {
          const requestId = p.requestID
          if (typeof requestId === "string") pendingQuestionIds.delete(requestId)
          break
        }

        case "session.deleted": {
          if (typeof sid === "string") {
            subagentSessionIds.delete(sid)
            busySessions.delete(sid)
            sessionStarts.delete(sid)
          }
          break
        }
      }
    }

    setTabTitle(`${projectName}: ready`)

    return {
      event: async ({ event }: any) => {
        try {
          handleV1(event)
        } catch (err: any) {
          console.error("[peon-ping] failed to handle event:", err?.message ?? err)
        }
      },
    }
  },

  /**
   * OpenCode 2.x entry point — verbatim from upstream (rev de4ada79),
   * plus a compat guard (see below).
   */
  setup: async (ctx: any) => {
    // opencode 1.18.x also runs an experimental v2 promise-plugin loader
    // (core ConfigExternalPlugin -> PluginPromise.fromPromise) whose
    // PluginContext exposes NO event API (only options/agent/aisdk/catalog/
    // command/integration/plugin/reference/skill). It matches this module on
    // the { id, setup } schema variant and calls setup(ctx) with that
    // context, so ctx.event is undefined there. No-op instead of throwing
    // into the TUI; real 2.x hosts expose ctx.event.subscribe and take the
    // full path below. Eventing on 1.x goes through server() above.
    if (!ctx?.event?.subscribe) return () => {}

    const projectName = path.basename(ctx?.location?.directory || process.cwd()) || "opencode"
    const windows = os.platform() === "win32"
    const peonScript = findPeonScript(windows)

    if (!peonScript) {
      warnNotInstalled(windows)
      return
    }

    const cwd = ctx?.location?.directory || process.cwd()
    function directoryIdentity(directory: string): string {
      let resolved = path.resolve(directory)
      // Hosts can retain the caller's symlink path in event locations while
      // loading the plugin at its canonical path (for example /tmp on macOS).
      try { resolved = fs.realpathSync(resolved) } catch {}
      return windows ? resolved.toLowerCase() : resolved
    }
    const pluginDirectory = directoryIdentity(cwd)
    // The host may load one physical directory through more than one alias.
    // Keep a single active bridge for that directory across plugin generations.
    const shared = globalThis as any
    const locationOwners: Map<string, Set<object>> = shared[LOCATION_OWNERS] ??= new Map()
    const owners = locationOwners.get(pluginDirectory) ?? new Set<object>()
    const owner = {}
    owners.add(owner)
    locationOwners.set(pluginDirectory, owners)
    const sessionId = `oc-${Date.now()}`
    const subagentSessionIds = new Set<string>()
    const busySessions = new Set<string>()
    const sessionStarts = new Map<string, number>()
    const pendingQuestionIds = new Set<string>()

    function firePeon(event: string, notificationType = ""): void {
      const payload = JSON.stringify({
        hook_event_name: event,
        notification_type: notificationType,
        cwd,
        session_id: sessionId,
        permission_mode: "",
        source: "opencode",
      })

      try {
        const proc = spawn(windows ? "powershell.exe" : "bash", windows
          ? ["-NoProfile", "-NonInteractive", "-File", peonScript!]
          : [peonScript!], {
          stdio: ["pipe", "ignore", "ignore"],
        })
        // Launch failures and early child exits arrive asynchronously, outside
        // this try/catch. Notifications must never take down the plugin host.
        proc.on("error", () => {})
        proc.stdin?.on("error", () => {})
        proc.stdin?.write(payload)
        proc.stdin?.end()
        proc.unref()
      } catch {}
    }

    function isSubagent(sid: unknown): boolean {
      return typeof sid === "string" && subagentSessionIds.has(sid)
    }

    /**
     * Map an OpenCode v2 event onto a peon.sh hook_event_name.
     *
     * v2 replaced the event taxonomy this adapter was written against; see
     * `docs/opencode-v2-events.md` for the full table. The cases below are the
     * only v2 events that map onto a peon-ping category.
     */
    async function handle(event: V2Event): Promise<void> {
      if (!SCOPED_EVENT_TYPES.has(event.type) || owners.values().next().value !== owner) return
      const data = event.data ?? {}
      const sid = data.sessionID ?? data.form?.sessionID
      // Deletion is silent cleanup. The host has already removed the session,
      // so a location lookup can no longer succeed. Other projects hold no
      // state for this globally unique session ID and are safe to clear too.
      if (event.type === "session.deleted") {
        if (typeof sid === "string") {
          subagentSessionIds.delete(sid)
          busySessions.delete(sid)
          sessionStarts.delete(sid)
        }
        return
      }
      let eventDirectory = event.location?.directory ?? data.location?.directory
      let parentID = data.parentID
      // Durable execution events have no location envelope. Resolve the
      // session through the actual host rather than treating them as local.
      if (!eventDirectory && typeof sid === "string") {
        const session = await ctx.session.get({ sessionID: sid })
        if (owners.values().next().value !== owner) return
        eventDirectory = session.location?.directory
        parentID = session.parentID
        if (!eventDirectory) return
      }
      if (eventDirectory && directoryIdentity(eventDirectory) !== pluginDirectory) return
      if (parentID && typeof sid === "string") subagentSessionIds.add(sid)

      switch (event.type) {
        case "session.created": {
          if (data.parentID && typeof data.sessionID === "string") subagentSessionIds.add(data.sessionID)
          break
        }

        // A new execution is both "a turn began" and, the first time we see a
        // session, "a session began". SessionStart is emitted first so the
        // debounce below suppresses the UserPromptSubmit that immediately
        // follows it, matching the pre-v2 behaviour.
        case "session.execution.started": {
          const sid = data.sessionID
          if (typeof sid !== "string" || isSubagent(sid) || busySessions.has(sid)) break
          busySessions.add(sid)
          const lastSessionStart = sessionStarts.get(sid)
          if (lastSessionStart === undefined) {
            sessionStarts.set(sid, Date.now())
            setTabTitle(`${projectName}: ready`)
            firePeon("SessionStart")
          } else if (Date.now() - lastSessionStart > 3000) {
            setTabTitle(`${projectName}: working`)
            firePeon("UserPromptSubmit")
          }
          break
        }

        case "session.execution.succeeded": {
          const sid = data.sessionID
          if (isSubagent(sid)) break
          if (sid) busySessions.delete(sid)
          setTabTitle(`\u25cf ${projectName}: done`)
          firePeon("Stop")
          break
        }

        case "session.execution.failed": {
          const sid = data.sessionID
          if (isSubagent(sid)) break
          if (sid) busySessions.delete(sid)
          setTabTitle(`\u25cf ${projectName}: error`)
          firePeon("PostToolUseFailure")
          break
        }

        case "session.execution.interrupted": {
          if (typeof data.sessionID === "string") busySessions.delete(data.sessionID)
          break
        }

        case "permission.asked": {
          if (isSubagent(data.sessionID)) break
          setTabTitle(`\u25cf ${projectName}: needs approval`)
          firePeon("PermissionRequest")
          break
        }

        // v2 renamed the "agent needs input" elicitation surface from
        // question.* to form.*.
        case "form.created": {
          const form = data.form
          const sid = form?.sessionID
          if (isSubagent(sid)) break
          const requestId = form?.id
          if (typeof requestId !== "string" || pendingQuestionIds.has(requestId)) break
          if (pendingQuestionIds.size >= MAX_PENDING_QUESTION_IDS) {
            pendingQuestionIds.delete(pendingQuestionIds.values().next().value!)
          }
          pendingQuestionIds.add(requestId)
          setTabTitle(`\u25cf ${projectName}: needs input`)
          firePeon("Notification", "elicitation_dialog")
          break
        }

        case "form.replied":
        case "form.cancelled": {
          const requestId = data.id
          if (typeof requestId === "string") pendingQuestionIds.delete(requestId)
          break
        }
      }
    }

    setTabTitle(`${projectName}: ready`)

    const controller = new AbortController()

    // A rejection escaping this loop would take down the plugin generation, and
    // an aborted stream is the normal shutdown path.
    void (async () => {
      for await (const event of ctx.event.subscribe({ signal: controller.signal })) {
        try {
          await handle(event as V2Event)
        } catch (err: any) {
          console.error("[peon-ping] failed to handle event:", err?.message ?? err)
        }
      }
    })().catch((err: any) => {
      if (!controller.signal.aborted) console.error("[peon-ping] event stream ended:", err?.message ?? err)
    })

    return () => {
      controller.abort()
      owners.delete(owner)
      if (owners.size === 0) locationOwners.delete(pluginDirectory)
    }
  },
}
