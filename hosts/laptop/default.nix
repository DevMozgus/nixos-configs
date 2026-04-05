# Laptop host entry: common + optional + TLP, lid switch, NetworkManager
{ pkgs, ... }:
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
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  services.tlp.enable = true;

  programs.steam.enable = true;

  services.logind.settings.Login = {
    HandleLidSwitch = "suspend";
    HandleLidSwitchExternalPower = "ignore";
  };

  environment.systemPackages = with pkgs; [
    brightnessctl
    acpi
  ];

  system.stateVersion = "25.05";
}
