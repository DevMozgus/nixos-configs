# BlueZ + blueman Bluetooth stack
{ lib, ... }:
{
  # linux-firmware ships the Bluetooth controller firmware (Intel ibt-*.sfi,
  # Realtek rtl_bt/*, …) that btusb/btintel load at bring-up. Without it the
  # hci device never initializes and bluetoothd (plus blueman and the
  # Quickshell bar) reports "no adapters detected". Nothing else in this flake
  # sets this option — the placeholder hardware-configuration.nix files lack
  # the line nixos-generate-config would emit. mkDefault so a future real
  # hardware-configuration.nix can override it explicitly.
  hardware.enableRedistributableFirmware = lib.mkDefault true;

  hardware.bluetooth = {
    enable = true;
    # Adapter stays powered off at boot (Policy.AutoEnable = false in
    # main.conf). It is still detected — the Quickshell bar shows it as
    # Disabled and the toggle powers it on via BlueZ Powered on demand.
    powerOnBoot = false;

    settings.General.Experimental = true; # Battery1 reports → battery % in the Quickshell popover
  };

  services.blueman.enable = true;
}
