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
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";
  networking.networkmanager.enable = true;

  services.tlp.enable = true;

  programs.steam.enable = true;

  programs._1password.enable = true;
  programs._1password-gui = {
    enable = true;
    polkitPolicyOwners = [ "nicola" ];
  };

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
