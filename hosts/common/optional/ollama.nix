# Local AI: Ollama (ROCm) + Open WebUI — desktop only, localhost-bound.
# Every side effect is gated on services.ollama.enable so hosts that inherit
# this module but disable the service (the VM uses lib.mkForce false) also
# skip Open WebUI, the CLI package and the Modelfile loader.
{ config, lib, pkgs, ... }:

let
  ollamaCfg = config.services.ollama;

  # Declarative Modelfiles — committed here as the source of truth for custom
  # models. `ollama create <name> -f <file>` is idempotent: it rebuilds the
  # model layer only when the Modelfile content changes.
  modelfiles = {
    deep-ocean-assistant = pkgs.writeText "deep-ocean-assistant.Modelfile" ''
      FROM hf.co/hellork/Qwen3.6-12B-IQ-Ultra-Heretic-Uncensored-Thinking-V2-Hightop-Q4_K_M-GGUF
      SYSTEM """You are a concise assistant running fully offline on a local machine. Prefer short, factual answers. Say when you are unsure."""
      PARAMETER temperature 0.4
    '';
  };
in
{
  services.ollama = {
    enable = true;
    # ROCm build — required for GPU acceleration on the RX 7900 XT (gfx1100).
    # The default pkgs.ollama package would fall back to CPU inference.
    package = pkgs.ollama-rocm;
    # gfx1100 is natively supported by ROCm 6.x; the override pins detection
    # in case runtime GPU enumeration misses it (see nixpkgs#405846).
    rocmOverrideGfx = "11.0.0";
    # Localhost-only API. security.nix firewall is default-deny inbound and
    # stays untouched (openFirewall = false is the default).
    host = "127.0.0.1";
    port = 11434;
    # Final model set (~57 GB on disk; all refs verified pullable Aug 2026).
    #  - gemma-4 Esper4FableComposer + Qwen3.6 V2-Hightop: the 12B picks,
    #    via their only GGUF mirrors, tag-pinned — tagless hf.co pulls
    #    resolve to an arbitrary quant file.
    #  - batiai IQ4_XS / Blackfrost-AI Q4_K_M: GGUF substitutes for the
    #    unloadable 27B requests (EXL3 is CUDA-only, NVFP4 needs Blackwell).
    #    IQ4_XS fits 20 GB VRAM tightly; Q4_K_M runs with partial CPU
    #    offload — slow but working.
    #  - gemma4:e4b: multimodal (text+image+audio). llama3.2-vision:11b
    #    pulls fine but its mllama architecture fails to load in every
    #    current ollama (never fully implemented in llama.cpp, dropped
    #    from the new engine — ollama issue #16490). gemma4 runs natively
    #    on the new engine with ROCm, ~6 GB VRAM.
    #  - nomic-embed-text: embeddings for Open WebUI RAG.
    # Skipped: DavidAU V1 — no GGUF exists anywhere on HF (all mirrors are
    # V2-Hightop). Pull more freely with `ollama pull` — syncModels = false
    # keeps ad-hoc pulls across rebuilds.
    loadModels = [
      "hf.co/mradermacher/gemma-4-12B-it-Esper4FableComposer-GGUF:Q4_K_M"
      "hf.co/hellork/Qwen3.6-12B-IQ-Ultra-Heretic-Uncensored-Thinking-V2-Hightop-Q4_K_M-GGUF"
      "hf.co/batiai/Qwen3.8-27B-GGUF:IQ4_XS"
      "hf.co/Blackfrost-AI/Qwen3.8-27B-ABLITERATED-GGUF:Q4_K_M"
      "gemma4:e4b"
      "nomic-embed-text"
    ];
    syncModels = false;
    # Open WebUI's system prompt + tools preamble alone weighs ~5.5K
    # tokens, and ollama's VRAM-tiered default context is only 4096 on a
    # 20 GB card — every "basic" chat 400s with exceeds_context_size before
    # the user message even arrives (observed with 0.32.13). 32K keeps the
    # 12Bs fully in VRAM (KV ~1-3 GB); the 27Bs offload a few more layers
    # to CPU. Per-request num_ctx (e.g. Open WebUI per-model Advanced
    # Parameters) still overrides this for speed tuning.
    environmentVariables = {
      OLLAMA_CONTEXT_LENGTH = "32768";
    };
  };

  # Web chat frontend, bound to localhost as well.
  services.open-webui = lib.mkIf ollamaCfg.enable {
    enable = true;
    host = "127.0.0.1";
    port = 8080;
    environment = {
      # Point Open WebUI at the local Ollama API. Both spellings are set
      # because the upstream variable name changed between versions and
      # unknown keys are ignored.
      OLLAMA_API_BASE_URL = "http://127.0.0.1:11434";
      WEBUI_OLLAMA_BASE_URL = "http://127.0.0.1:11434";
    };
  };

  # User-facing CLI (`ollama run`, `ollama ps`, …) — talks to the daemon
  # over HTTP, so the same package as the service is fine.
  environment.systemPackages = lib.mkIf ollamaCfg.enable [ ollamaCfg.package ];

  # Apply the declarative Modelfiles after the service (and the module's own
  # ollama-model-loader.service, which pulls loadModels) are up. `ollama
  # create` goes through the HTTP API, so a DynamicUser with no state access
  # is sufficient (same pattern as the upstream model-loader unit).
  systemd.services.ollama-modelfile-loader = lib.mkIf ollamaCfg.enable {
    description = "Create custom Ollama models from declarative Modelfiles";
    after = [
      "ollama.service"
      "ollama-model-loader.service"
    ];
    wants = [ "ollama.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      DynamicUser = true;
      # First boot may queue behind initial model pulls — don't let the
      # default 90s job timeout kill the readiness poll below.
      TimeoutStartSec = "10min";
      # `ollama create` resolves its FROM blob server-side; on first boot
      # the base model may still be downloading — retry instead of failing.
      Restart = "on-failure";
      RestartSec = "30s";
    };
    environment = {
      OLLAMA_HOST = "${ollamaCfg.host}:${toString ollamaCfg.port}";
      # The ollama CLI (0.32.x) panics with "$HOME is not defined" in
      # envconfig when HOME is unset, and DynamicUser units get no HOME by
      # default. Mirror the upstream model-loader unit, which sets
      # HOME=/var/lib/ollama for the same reason — the CLI only talks to
      # the HTTP API here, so nothing is ever written there.
      HOME = ollamaCfg.home;
    };
    path = [ ollamaCfg.package ];
    script =
      ''
        # Wait for the API to come up (first boot may still be pulling models).
        for i in $(seq 1 60); do
          if ollama list >/dev/null 2>&1; then
            break
          fi
          sleep 5
        done
      ''
      + lib.concatStringsSep "\n" (
        lib.mapAttrsToList (
          name: file: "ollama create ${name} -f ${file}"
        ) modelfiles
      );
  };
}
