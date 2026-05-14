# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.sddmOmarchy}/share/sddm/themes/omarchy";
  };

  environment.systemPackages = [ pkgs.sddmOmarchy ];

  # Ensure uwsm is in the display-manager service PATH so the UWSM session
  # desktop file (Exec=uwsm start …) can actually be executed by SDDM.
  systemd.services.display-manager.path = [ pkgs.uwsm ];

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Enable GNOME Keyring daemon and unlock it on SDDM login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
