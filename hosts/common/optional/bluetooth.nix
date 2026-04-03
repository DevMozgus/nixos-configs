# BlueZ + blueman Bluetooth stack
{ pkgs, ... }:
{
  hardware.bluetooth = {
    enable = false;
    powerOnBoot = false;
  };

  services.blueman.enable = true;
}
