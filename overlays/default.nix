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
    obsImageReaction = prev.callPackage ../pkgs/obs-image-reaction { };
  })

  # obs-multi-rtmp — nixpkgs pins 0.6.0.1 (OBS 31 era); override to the
  # 0.7.4.x line that tracks OBS 32.x (0.7.4.4 targets OBS 32.2.1)
  (final: prev: {
    obs-studio-plugins = prev.obs-studio-plugins // {
      obs-multi-rtmp = prev.obs-studio-plugins.obs-multi-rtmp.overrideAttrs (old: rec {
        version = "0.7.4.4";
        src = final.fetchFromGitHub {
          owner = "sorayuki";
          repo = "obs-multi-rtmp";
          rev = version;
          hash = "sha256-2FwiERIV9xcaP3rJ9bKSv2ZXiwO1cF0L6oheR4HY3AY=";
        };
        # 0.7.x (obs-plugintemplate v2) finds Qt itself — 0.6-era fetchpatch obsolete
        patches = [ ];
        # Template installs straight to lib/obs-plugins + share/obs/obs-plugins;
        # the 0.6-era $out/dist move-up would fail against the new layout
        postInstall = "";
      });
    };
  })
]
