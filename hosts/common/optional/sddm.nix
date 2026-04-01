# SDDM display manager: Wayland backend, defaults to Hyprland (UWSM)
{ ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  services.displayManager.defaultSession = "hyprland-uwsm";
}
