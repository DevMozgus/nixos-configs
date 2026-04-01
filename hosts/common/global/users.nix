# User accounts, sudo, runtime password file
{ pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.nicola = {
    isNormalUser = true;
    description = "Nicola";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker" ];
    hashedPasswordFile = "/persist/passwords/nicola";
    shell = pkgs.zsh;
  };

  security.sudo.wheelNeedsPassword = true;
}
