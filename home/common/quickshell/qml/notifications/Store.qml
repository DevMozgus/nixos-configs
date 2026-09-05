pragma Singleton

// Store — the shell's notification backend.
//
// Exactly ONE NotificationServer lives here (the singleton guarantees
// it). Incoming notifications are gated on DND: while dnd is set only
// NotificationUrgency.Critical gets tracked (tracked = true) — the
// server discards everything else, but the copy below still lands in
// history so nothing is silently lost. History is a plain JS array
// (newest first, cap 100) persisted as JSON through FileView in the
// quickshell state dir. Live notifications are forwarded to the toast
// stack; the NotificationCenter renders the history.

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications

Singleton {
    id: root

    // ── Public API ──────────────────────────────────────────────────────
    readonly property var history: []     // newest-first record list
    property bool dnd: false
    property int unread: 0                // reset by markRead()

    signal newToast(var notif)
    signal historyChanged()

    readonly property alias center: notifCenter

    function markRead() {
        root.unread = 0;
    }

    function toggleDnd() {
        root.dnd = !root.dnd;
    }

    function clearAll() {
        root.history = [];
        root.unread = 0;
        root.historyChanged();
        root._persist();
    }

    // Drop one history entry (user-close in the center).
    function dismiss(key) {
        root.history = root.history.filter(r => r.key !== String(key));
        root.historyChanged();
        root._persist();
    }

    // ── History records ─────────────────────────────────────────────────
    // Plain-data copies: the server-owned Notification object dies once
    // dismissed/expired. `object` keeps the live reference while it
    // exists so actions stay invokable from the center.

    function _record(notif, live) {
        const actions = [];
        const rawActions = notif.actions ?? [];
        for (let i = 0; i < rawActions.length; i++) {
            const a = rawActions[i];
            if (!a)
                continue;
            actions.push({
                identifier: String(a.identifier ?? ""),
                text: String(a.text ?? "")
            });
        }
        const record = {
            key: String(notif.id),
            appName: String(notif.appName ?? ""),
            summary: String(notif.summary ?? ""),
            body: String(notif.body ?? ""),
            appIcon: String(notif.appIcon ?? ""),
            urgency: Number(notif.urgency ?? 1),
            time: Date.now(),
            actions: actions,
            object: live ? notif : null
        };
        // Same-key re-arrival = notification update: replace in place
        // (its toast deadline is refreshed by Toasts.push).
        root.history = [record].concat(root.history.filter(r => r.key !== record.key)).slice(0, 100);
        root.unread += 1;
        root.historyChanged();
        root._persist();
    }

    // Actions of the live notification behind a record, if it still
    // exists (touching a destroyed notification throws — guard it).
    function _liveActions(record) {
        try {
            if (record.object && record.object.actions)
                return record.object.actions ?? [];
        } catch (e) {
            // notification object already destroyed server-side
        }
        return [];
    }

    function _invokeAction(record, identifier) {
        const action = root._liveActions(record).find(a => a && a.identifier === identifier);
        if (!action)
            return false;
        action.invoke();
        return true;
    }

    // ── Server ──────────────────────────────────────────────────────────
    NotificationServer {
        id: server

        onNotification: notif => {
            const critical = notif.urgency === NotificationUrgency.Critical;
            if (root.dnd && !critical) {
                // DND: record silently but do NOT set tracked — the
                // server discards the notification.
                root._record(notif, false);
                return;
            }
            notif.tracked = true;
            root._record(notif, true);
            root.newToast(notif);
            toasts.push(notif);
        }
    }

    // ── Windows (single global instances, primary screen) ───────────────
    Toasts {
        id: toasts
    }

    NotificationCenter {
        id: notifCenter
    }

    // ── Persistence ─────────────────────────────────────────────────────
    FileView {
        id: stateFile

        path: Quickshell.statePath("notifications.json")
        watchChanges: false

        onLoaded: root._restore(text())
    }

    onDndChanged: root._persist()

    function _restore(text) {
        try {
            const data = JSON.parse(text);
            if (data !== null && typeof data === "object") {
                if (typeof data.dnd === "boolean")
                    root.dnd = data.dnd;
                if (Array.isArray(data.history)) {
                    root.history = data.history
                            .filter(e => e !== null && typeof e === "object")
                            .map(e => Object.assign({}, e, { object: null }))
                            .slice(0, 100);
                    root.historyChanged();
                }
            }
        } catch (e) {
            console.warn("[mdo] notifications: unreadable state file:", e);
        }
    }

    function _persist() {
        const slim = root.history.map(r => ({
            key: r.key,
            appName: r.appName,
            summary: r.summary,
            body: r.body,
            appIcon: r.appIcon,
            urgency: r.urgency,
            time: r.time,
            actions: r.actions
        }));
        try {
            stateFile.setText(JSON.stringify({ dnd: root.dnd, history: slim }));
        } catch (e) {
            console.warn("[mdo] notifications: could not persist state:", e);
        }
    }
}
