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
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  programs.steam.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nicola" ];
  };

  system.stateVersion = "25.05";
}
