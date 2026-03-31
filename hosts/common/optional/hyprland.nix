# Hyprland compositor: portals, polkit, PAM, UWSM
{ pkgs, ... }:
{
  programs.hyprland = {
    enable = true;
    withUWSM = true;
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-hyprland ];
  };

  security.polkit.enable = true;
  security.rtkit.enable = true;

  security.pam.services.hyprlock = {};

  programs.dconf.enable = true;
}
