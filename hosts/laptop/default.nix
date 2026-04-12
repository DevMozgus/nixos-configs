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
    ../common/optional/codecs.nix
    ../common/optional/security.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "laptop";

  powerManagement.enable = true;

  services.thermald.enable = true;

  services.tlp = {
    enable = true;
    settings = {
      CPU_SCALING_GOVERNOR_ON_AC = "performance";
      CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

      CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
      CPU_ENERGY_PERF_POLICY_ON_BAT = "power";

      CPU_MIN_PERF_ON_AC = 0;
      CPU_MAX_PERF_ON_AC = 100;
      CPU_MIN_PERF_ON_BAT = 0;
      CPU_MAX_PERF_ON_BAT = 60;
    };
  };

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
