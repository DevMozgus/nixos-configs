# hosts/common/global/default.nix — Aggregates all global NixOS modules
{ pkgs, ... }:
{
  imports = [
    ./nix.nix
    ./locale.nix
    ./users.nix
    ./boot.nix
  ];

  # Stylix theming — single source of truth
  stylix = {
    enable = true;
    autoEnable = true;
    polarity = "dark";
    base16Scheme = ./../../../themes/material-deep-ocean.yaml;
    image = ./../../../assets/wallpaper.png;
    imageScaleMode = "fill";

    fonts = {
      monospace = {
        package = pkgs.nerd-fonts.jetbrains-mono;
        name = "JetBrainsMono Nerd Font";
      };
      sansSerif = {
        package = pkgs.inter;
        name = "Inter";
      };
      emoji = {
        package = pkgs.noto-fonts-color-emoji;
        name = "Noto Color Emoji";
      };
    };

    cursor = {
      package = pkgs.bibata-cursors;
      name = "Bibata-Modern-Classic";
      size = 24;
    };

    opacity.terminal = 0.95;
  };
}
