# Hyprland compositor: portals, polkit, PAM, UWSM
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  # Register the UWSM-managed Hyprland session. `programs.hyprland.withUWSM`
  # only enables uwsm (programs.uwsm.enable = true); it does NOT create a
  # display-manager session file. Declaring waylandCompositors.hyprland
  # generates share/wayland-sessions/hyprland-uwsm.desktop
  # (Exec=uwsm start -F -- …/Hyprland), which is what
  # services.displayManager.defaultSession = "hyprland-uwsm" and the omarchy
  # SDDM theme select. Without it there is no uwsm session to launch, so SDDM
  # falls back to plain Hyprland and the session starts without proper UWSM
  # systemd management — resulting in a black screen with no interaction.
  # See: https://wiki.hyprland.org/Useful-Utilities/Systemd-start/
  programs.uwsm.waylandCompositors.hyprland = {
    prettyName = "Hyprland";
    comment = "Hyprland compositor managed by UWSM";
    binPath = "/run/current-system/sw/bin/Hyprland";
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
