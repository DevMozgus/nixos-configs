# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.sddmOmarchy}/share/sddm/themes/omarchy";
  };

  environment.systemPackages = [ pkgs.sddmOmarchy ];

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Enable GNOME Keyring daemon and unlock it on SDDM login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
