# User accounts, sudo, runtime password file
{ pkgs, ... }:
{
  programs.zsh.enable = true;

  users.users.nicola = {
    isNormalUser = true;
    description = "Nicola";
    extraGroups = [
      "wheel"
      "video"
      "audio"
      "networkmanager"
      "docker"
    ];
    # hashedPasswordFile is read on every activation for new users.
    # On first install the file won't exist yet, so initialPassword
    # provides a working password for the first login ("nixos").
    # After first login, change it with: passwd
    # Optionally create the persistent file for declarative management:
    #   mkdir -p /persist/passwords
    #   mkpasswd -m sha-512 | sudo tee /persist/passwords/nicola
    #   sudo chmod 600 /persist/passwords/nicola
    hashedPasswordFile = "/persist/passwords/nicola";
    initialPassword = "nixos";
    shell = pkgs.zsh;
  };

  security.sudo = {
    wheelNeedsPassword = true;
    extraConfig = ''
      Defaults timestamp_timeout=30
    '';
  };
}
