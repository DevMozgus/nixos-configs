# VM host: QEMU VM for testing, no disko, auto-login, VIRGL for Wayland
{ lib, modulesPath, pkgs, ... }:
{
  imports = [
    (modulesPath + "/virtualisation/qemu-vm.nix")
    ../desktop
  ];

  # Disable disko in VM — no disk partitioning needed
  disko.devices = lib.mkForce {};

  # Remove disko-generated filesystem entries
  fileSystems = lib.mkForce {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };
  };

  # VM settings
  virtualisation = {
    memorySize = 4096;
    cores = 4;
    diskSize = 8192;
    qemu.options = [
      "-device" "virtio-vga-gl"
      "-display" "gtk,gl=on"
    ];
  };

  # Auto-login for testing
  users.users.nicola.initialPassword = lib.mkForce "test";
  services.getty.autologinUser = "nicola";

  # Disable Plymouth in VM
  boot.plymouth.enable = lib.mkForce false;

  # Disable local AI stack inherited from ../desktop — the VM has no dGPU
  # and a 4 GB memory cap; ROCm inference is pointless here. The ollama
  # module gates Open WebUI, the CLI package and the Modelfile loader on
  # this same switch.
  services.ollama.enable = lib.mkForce false;

  # Disable ComfyUI inherited from ../desktop — same reason: no dGPU,
  # 4 GB memory cap. The flake module gates its user, package and service
  # on this switch.
  services.comfyui.enable = lib.mkForce false;

  # Disable LUKS in VM
  boot.initrd.luks.devices = lib.mkForce {};

  networking.hostName = lib.mkForce "vm";

  system.stateVersion = "25.05";
}
