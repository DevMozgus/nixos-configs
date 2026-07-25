# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    theme = "${pkgs.sddmOmarchy}/share/sddm/themes/omarchy";
    # Cursor theme/size for the greeter. The actual pointer is rendered by
    # weston (the greeter compositor) via XCURSOR_THEME below; this setting is
    # belt-and-suspenders for the Qt greeter side.
    settings.Theme = {
      CursorTheme = "Bibata-Modern-Classic";
      CursorSize = 24;
    };
  };

  # The cursor package must be installed system-wide so weston (the SDDM
  # Wayland greeter compositor) can find it — Stylix only themes the
  # home-manager user session, not the greeter.
  environment.systemPackages = [ pkgs.sddmOmarchy pkgs.bibata-cursors ];

  # The SDDM Wayland greeter runs under weston. weston inherits this
  # environment and uses XCURSOR_THEME to render the mouse cursor; without a
  # system-wide cursor package (above) and this env var, no pointer appears on
  # the login screen. `uwsm` is kept on PATH so the UWSM session desktop file
  # (Exec=uwsm start …) can be launched by SDDM.
  systemd.services.display-manager = {
    path = [ pkgs.uwsm ];
    environment = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "24";
    };
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Enable GNOME Keyring daemon and unlock it on SDDM login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
