# User accounts, sudo, runtime password file
{ ... }:
{
  users.users.nicola = {
    isNormalUser = true;
    description = "Nicola";
    extraGroups = [ "wheel" "video" "audio" "networkmanager" "docker" ];
    hashedPasswordFile = "/persist/passwords/nicola";
  };

  security.sudo.wheelNeedsPassword = true;
}
