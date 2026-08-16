# Hyprland compositor: portals, polkit, PAM, UWSM
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    # Enables UWSM (programs.uwsm.enable) so Hyprland runs as a proper systemd
    # graphical session. The hyprland package itself ships the
    # `hyprland-uwsm.desktop` session (Exec=`uwsm start -e -D Hyprland
    # hyprland.desktop`, DesktopNames=Hyprland), which SDDM's
    # defaultSession = "hyprland-uwsm" launches, and `passthru.providedSessions`
    # registers it with the display manager.
    #
    # Do NOT manually declare `programs.uwsm.waylandCompositors.hyprland`. That
    # option generates a *competing* hyprland-uwsm.desktop whose Exec points
    # uwsm at a raw binary and which has NO DesktopNames field, so uwsm derives
    # XDG_CURRENT_DESKTOP from the binary basename (e.g. "start-hyprland:Hyprland")
    # — triggering Hyprland's "XDG managed externally" warning and breaking the
    # desktop portal / screen sharing. The package-provided session instead feeds
    # hyprland.desktop to uwsm, giving both the start-hyprland watchdog and a
    # correct XDG_CURRENT_DESKTOP=Hyprland.
    # Refs: https://wiki.hyprland.org/Useful-Utilities/Systemd-start/
    #       https://github.com/hyprwm/Hyprland/discussions/12661
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  security.pam.services.hyprlock = { };

  programs.dconf.enable = true;

  services.udisks2.enable = true;

  # Enable native Wayland rendering for Electron apps including VS Code
  environment.sessionVariables.NIXOS_OZONE_WL = "1";
}
