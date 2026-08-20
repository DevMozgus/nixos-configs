# Local AI image generation: ComfyUI (ROCm) — desktop only, localhost-bound.
# Uses the comfyui-nix flake (github:utensils/comfyui-nix) instead of
# nixpkgs' pkgs.comfyui: the nixpkgs package is CPU-only unless
# config.rocmSupport is flipped globally (rebuilding half the closure),
# while the flake's rocm build ships pre-built PyTorch ROCm wheels from
# pytorch.org (~2 GB download, no compilation) and is upstream-validated
# on gfx1100 — the RX 7900 XT's architecture.
{ config, inputs, lib, ... }:

{
  imports = [ inputs.comfyui-nix.nixosModules.default ];

  # The flake's NixOS module resolves its package via pkgs.comfy-ui-rocm,
  # so its overlay must be present — it is wired centrally in
  # overlays/default.nix (same pattern as nix-vscode-extensions/NUR).
  # Importing the module also disables nixpkgs' own services.comfyui
  # module (nixos-unstable ships one) to avoid an option collision — all
  # services.comfyui.* options below come from the flake.

  services.comfyui = {
    enable = true;
    # ROCm build for the RX 7900 XT (gfx1100). The bundled ROCm 7.1
    # runtime officially supports gfx1100 — no HSA_OVERRIDE_GFX_VERSION
    # needed (unlike ollama's rocmOverrideGfx pin, which works around
    # ollama's own GPU enumeration, see nixpkgs#405846).
    gpuSupport = "rocm";
    # ComfyUI Manager for node/model installs from the UI. Runtime pip
    # installs land in a PEP 405 venv under dataDir — the Nix store stays
    # pure and read-only.
    enableManager = true;
    # Localhost-only like the ollama stack; the firewall stays
    # default-deny inbound (openFirewall = false is the default).
    listenAddress = "127.0.0.1";
    port = 8188;
    dataDir = "/var/lib/comfyui";
    # PyTorch SDPA attention is the sane path on AMD — no xformers or
    # flash-attn for ROCm (the rocm build already excludes xformers).
    # Also avoids the "HIP error: illegal memory access" some AMD setups
    # hit in the default attention path (Comfy-Org/ComfyUI#10997).
    extraArgs = [ "--use-pytorch-cross-attention" ];
  };

  # Z-Image Turbo (Tongyi-MAI) is natively supported — no custom nodes.
  # BF16 is the correct precision on RDNA3: gfx1100 has no FP8 hardware,
  # so fp8 checkpoints silently upcast to BF16 with zero VRAM savings.
  # 20 GB VRAM fits the BF16 DiT (~12 GB) + Qwen3-4B encoder (~8 GB)
  # through ComfyUI's default smart offloading. Grab the Comfy-Org
  # repackaged single files (https://huggingface.co/Comfy-Org/z_image_turbo)
  # into the data dir:
  #   models/diffusion_models/z_image_turbo_bf16.safetensors
  #   models/text_encoders/qwen_3_4b.safetensors
  #   models/vae/ae.safetensors  (same VAE as Flux)
  # either via Manager/Model Downloader at http://localhost:8188 or:
  #   sudo -u comfyui curl -L -o /var/lib/comfyui/models/<subdir>/<file> <url>
  # Then use the built-in "Z-Image Turbo" template (Workflow → Browse
  # Templates). Turbo is distilled for: 8-9 steps, CFG 1.0, res_multistep
  # sampler, simple scheduler, 1024x1024. The encoder loads via
  # CLIPLoader type "Lumina 2" — it is a Z-Image-specific Qwen3-4B, not
  # the stock instruct model, so only the Comfy-Org file works.
  #
  # Known AMD-only pitfall, do not preempt: if VAE decode ever crashes
  # with "HIP error: illegal memory access" on the bundled ROCm 7.1
  # wheels, the fix is the kernel param amdgpu.cwsr_enable=0 — add it to
  # hardware-configuration then, not speculatively now.
}
