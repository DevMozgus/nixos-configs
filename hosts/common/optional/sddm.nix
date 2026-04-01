# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "omarchy";
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  environment.systemPackages = [ pkgs.sddmOmarchy ];
}
