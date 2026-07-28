# Hyprland compositor: portals, polkit, PAM, UWSM
{ pkgs, lib, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # `withUWSM = true` registers the hyprland compositor with UWSM
  # (programs.uwsm.waylandCompositors.hyprland) and generates the
  # share/wayland-sessions/hyprland-uwsm.desktop session that SDDM's
  # defaultSession = "hyprland-uwsm" launches. However, the upstream module
  # sets binPath to the raw `Hyprland` binary, which launches Hyprland
  # directly and bypasses the `start-hyprland` watchdog wrapper. Hyprland
  # warns about this ("launched without start-hyprland") and you also lose the
  # --watchdog-fd systemd watchdog / crash-recovery integration that the
  # wrapper provides. Override binPath to the watchdog wrapper; the compositor
  # identity (and thus XDG_CURRENT_DESKTOP=Hyprland) still comes from the
  # attrset key, not the exec'd binary.
  # See: https://wiki.hyprland.org/Useful-Utilities/Systemd-start/
  #      https://github.com/hyprwm/Hyprland/discussions/12661
  programs.uwsm.waylandCompositors.hyprland = {
    prettyName = "Hyprland";
    comment = "Hyprland compositor managed by UWSM";
    binPath = lib.mkForce "/run/current-system/sw/bin/start-hyprland";
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
