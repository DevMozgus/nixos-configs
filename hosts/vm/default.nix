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

  # Disable LUKS in VM
  boot.initrd.luks.devices = lib.mkForce {};

  networking.hostName = lib.mkForce "vm";

  system.stateVersion = "25.05";
}
