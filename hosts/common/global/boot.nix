# systemd-boot, Plymouth, silent boot kernel params
{ pkgs, lib, ... }:
{
  boot.loader = {
    systemd-boot = {
      enable = true;
      configurationLimit = 10;
      editor = false;
    };
    efi.canTouchEfiVariables = true;
  };

  boot.plymouth = {
    enable = true;
    theme = lib.mkForce "material-deep-ocean";
    themePackages = [ pkgs.materialDeepOceanPlymouth ];
  };

  boot.initrd.systemd.enable = true;

  boot.consoleLogLevel = 3;
  boot.initrd.verbose = false;
  boot.kernelParams = [
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "udev.log_priority=3"
  ];
}
