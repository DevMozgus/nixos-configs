# Overlays: nix-vscode-extensions + NUR + custom packages
{ inputs }:
[
  # nix-vscode-extensions — provides pkgs.vscode-marketplace
  inputs.nix-vscode-extensions.overlays.default

  # NUR — provides pkgs.nur.repos.rycee.firefox-addons
  inputs.nur.overlays.default

  # comfyui-nix — provides pkgs.comfy-ui-rocm (pre-built PyTorch ROCm
  # wheels) for hosts/common/optional/comfyui.nix
  inputs.comfyui-nix.overlays.default

  # Custom packages overlay
  (final: prev: {
    materialDeepOceanPlymouth = prev.callPackage ../pkgs/plymouth-material-deep-ocean {
      logo = ../assets/logo.png;
    };
    sddmOmarchy = prev.callPackage ../pkgs/sddm-omarchy {
      wallpaper = ../assets/wallpaper3.png;
    };
    firefoxAddonOpenInMpv = prev.callPackage ../pkgs/firefox-addon-open-in-mpv { };
    ohMyOpencodeSlim = prev.callPackage ../pkgs/oh-my-opencode-slim { };
  })
]
