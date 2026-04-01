# Overlays: nix-vscode-extensions + NUR + custom packages
{ inputs }:
[
  # nix-vscode-extensions — provides pkgs.vscode-marketplace
  inputs.nix-vscode-extensions.overlays.default

  # NUR — provides pkgs.nur.repos.rycee.firefox-addons
  inputs.nur.overlays.default

  # Custom packages overlay
  (final: prev: {
    materialDeepOceanPlymouth = prev.callPackage ../pkgs/plymouth-material-deep-ocean {
      nixosIcons = prev.nixos-icons;
    };
    sddmOmarchy = prev.callPackage ../pkgs/sddm-omarchy {
      nixosIcons = prev.nixos-icons;
    };
  })
]
