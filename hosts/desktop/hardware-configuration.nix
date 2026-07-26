# Placeholder — generate on target machine with: nixos-generate-config --no-filesystems --root /mnt
{ config, lib, modulesPath, ... }:
{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  # Replace with actual hardware detection output after running nixos-generate-config
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];

  # Load amdgpu in stage-1 (initrd) so the RX 7900 XT is ready before the
  # compositor starts. Without this, amdgpu initialises ~51s into boot (well
  # after SDDM/Hyprland launch), leaving only the render-less simpledrm (EFI
  # framebuffer) present — Hyprland either latches onto it (black screen) or,
  # if pinned to the not-yet-present amdgpu, aborts with "Found no gpus".
  # Loading it in initrd also makes amdgpu claim card0 (it takes over the
  # framebuffer from simpledrm), so it is the primary device — AND it keeps
  # the LUKS/early-boot console (no brick risk).
  hardware.amdgpu.initrd.enable = true;
}
