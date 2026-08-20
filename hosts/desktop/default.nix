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
    ../common/optional/wireguard.nix
    ../common/optional/codecs.nix
    ../common/optional/beads-viewer.nix
    ../common/optional/security.nix
    ../common/optional/ollama.nix
    ../common/optional/comfyui.nix
    ./hardware-configuration.nix
  ];

  networking.hostName = "desktop";

  # Pin Hyprland/Aquamarine to the discrete amdgpu (RX 7900 XT) at card1.
  # simpledrm is an EFI-framebuffer *platform* driver that binds card0 at
  # kernel init — earlier than amdgpu — even though amdgpu now loads in the
  # initrd (see hardware-configuration.nix). So amdgpu ends up on card1 while
  # card0 (simpledrm) has no hardware rendering. Without this pin Hyprland
  # grabs card0 and paints a black screen; with it, Aquamarine uses card1.
  #
  # card1 is stable on this box: simpledrm always claims card0 and the 7900 XT
  # is the only other DRM device. Do NOT use the /dev/dri/by-path symlink here
  # — its PCI address contains ':' (pci-0000:03:00.0-card), and Aquamarine
  # parses AQ_DRM_DEVICES with ':' as the device separator, which splits the
  # path into garbage and aborts with "Found no gpus to use".
  # Ref: https://github.com/hyprwm/aquamarine/issues/301
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/card1";

  programs.steam.enable = true;

  system.stateVersion = "25.05";
}
