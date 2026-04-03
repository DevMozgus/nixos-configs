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

  # Enable GNOME Keyring daemon and unlock it on SDDM login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
