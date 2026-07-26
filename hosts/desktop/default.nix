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

  # Pin Hyprland/Aquamarine to the discrete amdgpu (RX 7900 XT) only.
  # simpledrm grabs /dev/dri/card0 early (EFI framebuffer, no HW rendering),
  # forcing amdgpu onto card1; without this Hyprland latches onto the
  # render-less card0 and shows a black screen.
  #
  # IMPORTANT: use the plain /dev/dri/cardN node, NOT the by-path symlink.
  # Aquamarine parses AQ_DRM_DEVICES with ':' as the device separator, and
  # PCI by-path names contain colons (pci-0000:03:00.0-card), which makes
  # Aquamarine split the path into garbage tokens and abort with
  # "Found no gpus to use". card1 is stable on this box: simpledrm always
  # claims card0 and the 7900 XT is the only other DRM device.
  # Refs: https://github.com/hyprwm/aquamarine/issues/301
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";

  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
