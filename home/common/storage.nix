# Auto-mount external drives (USB, etc.) via udiskie + udisks2
{ pkgs, ... }:
{
  services.udiskie = {
    enable = true;
    automount = true;
    notify = true;
    tray = "auto";
    settings = {
      program_options = {
        file_manager = "${pkgs.kdePackages.dolphin}/bin/dolphin";
      };
    };
  };
}
