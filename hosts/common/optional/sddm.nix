# SDDM display manager: Wayland backend, omarchy-style theme, defaults to Hyprland (UWSM)
{ pkgs, lib, ... }:
{
  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
    # weston's kiosk shell ships no cursor code at all, so the greeter
    # pointer stays invisible under it (sddm#1884) even with every
    # XCURSOR_* env var and fallback theme in place. kwin renders cursors
    # itself and reads XCURSOR_THEME/XCURSOR_SIZE from the greeter
    # environment below — the proven combination since NixOS 24.05
    # (nixpkgs PR #295839; Plasma defaults to it). The NVIDIA greeter
    # crash caveat (#311450/#496361) does not apply: both hosts are
    # AMD/Intel. The module auto-wires layer-shell-qt for the greeter.
    wayland.compositor = "kwin";
    theme = "${pkgs.sddmOmarchy}/share/sddm/themes/omarchy";
    # Note: Theme.CursorTheme is inert for the Wayland pointer (confirmed
    # upstream in sddm#1996); kept as belt-and-suspenders for the X11 path.
    settings.Theme = {
      CursorTheme = "Bibata-Modern-Classic";
      CursorSize = 24;
    };
  };

  # The cursor package must be installed system-wide so the greeter
  # compositor (kwin) can find it — Stylix only themes the
  # home-manager user session, not the greeter.
  environment.systemPackages = [ pkgs.sddmOmarchy pkgs.bibata-cursors ];

  # Root cause of the invisible greeter pointer: weston's kiosk shell contains
  # no cursor code at all — the pointer image comes from the Qt greeter client
  # (libwayland-cursor), and when it cannot resolve the named theme it falls
  # back to asking for the "default" theme, which does not exist on NixOS —
  # Qt then gives up and renders no pointer at all. fallbackCursorThemes
  # generates share/icons/default/index.theme with
  # Inherits=Bibata-Modern-Classic inside /run/current-system/sw/share/icons
  # (same mechanism the nixpkgs plasma6/cosmic modules use for this exact bug
  # class), so every cursor loader in the greeter resolves a real image.
  xdg.icons.fallbackCursorThemes = [ "Bibata-Modern-Classic" ];

  # The greeter unit does not source /etc/set-environment, so without
  # XCURSOR_PATH the xcursor loader
  # only searches FHS paths (~/.icons, /usr/share/icons, …) that don't exist on
  # NixOS — XCURSOR_THEME/SIZE alone then load no cursor image at all and no
  # pointer is visible on the login screen. /run/current-system/sw/share/icons
  # works because xdg.icons (enabled by default) links /share/icons from
  # systemPackages, where pkgs.bibata-cursors (above) provides
  # Bibata-Modern-Classic. `uwsm` is kept on PATH so the UWSM session desktop
  # file (Exec=uwsm start …) can be launched by SDDM.
  systemd.services.display-manager = {
    path = [ pkgs.uwsm ];
    environment = {
      XCURSOR_THEME = "Bibata-Modern-Classic";
      XCURSOR_SIZE = "24";
      XCURSOR_PATH = lib.concatStringsSep ":" [
        "/run/current-system/sw/share/icons"
        "/run/current-system/sw/share/pixmaps"
      ];
    };
  };

  services.displayManager.defaultSession = "hyprland-uwsm";

  # Enable GNOME Keyring daemon and unlock it on SDDM login
  services.gnome.gnome-keyring.enable = true;
  security.pam.services.sddm.enableGnomeKeyring = true;
}
