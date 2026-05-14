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
    # Persistent password read from /persist on every boot.
    # Falls back to initialPassword when the file doesn't exist yet
    # (e.g. first boot after install). After first login, set the
    # persistent hash with:
    #   mkdir -p /persist/passwords
    #   echo "$(mkpasswd -m sha-512)" | sudo tee /persist/passwords/nicola
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
