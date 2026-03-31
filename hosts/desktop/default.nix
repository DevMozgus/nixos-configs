# Desktop host entry: imports common + optional modules
{ ... }:
{
  imports = [
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/audio.nix
    ../common/optional/bluetooth.nix
    ../common/optional/docker.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  system.stateVersion = "25.05";
}
