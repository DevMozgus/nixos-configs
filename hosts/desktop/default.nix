# Desktop host entry: imports common + optional modules
{ ... }:
{
  imports = [
    ../common/global
    ../common/optional/hyprland.nix
    ../common/optional/sddm.nix
    ../common/optional/audio.nix
    ../common/optional/bluetooth.nix
    ../common/optional/docker.nix
    ../common/optional/network-manager.nix
    ../common/optional/1password.nix
    ../common/optional/netbird.nix
    ../common/optional/codecs.nix
    ../common/optional/security.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
