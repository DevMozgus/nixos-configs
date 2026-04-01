# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "omarchy";
    settings.Theme.ThemeDir = "${pkgs.sddmOmarchy}/share/sddm/themes";
  };

  services.displayManager.defaultSession = "hyprland-uwsm";
}
