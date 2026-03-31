# rofi-wayland launcher — Stylix auto-applies theme
{ pkgs, ... }:
{
  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "kitty";
    location = "center";
    extraConfig = {
      show-icons = true;
      display-drun = "Apps";
      drun-display-format = "{name}";
    };
  };
}
