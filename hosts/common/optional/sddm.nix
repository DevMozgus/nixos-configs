# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "omarchy";
    extraPackages = [ pkgs.sddmOmarchy ];
  };

  environment.systemPackages = [ pkgs.sddmOmarchy ];

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Unlock GNOME Keyring on login so VS Code can access the secret service
  security.pam.services.sddm.enableGnomeKeyring = true;
}
