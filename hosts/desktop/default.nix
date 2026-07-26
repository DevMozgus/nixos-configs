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
    ../common/optional/beads-viewer.nix
    ../common/optional/security.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # No AQ_DRM_DEVICES pin: amdgpu is loaded in the initrd (see
  # hardware-configuration.nix), so it claims card0 and is the primary DRM
  # device; Hyprland picks it up automatically. A static card-number pin is
  # fragile — card1 disappeared when amdgpu hadn't loaded yet (crash), and PCI
  # by-path values break Aquamarine's ':' device separator. Refs:
  # https://github.com/hyprwm/aquamarine/issues/301

  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
