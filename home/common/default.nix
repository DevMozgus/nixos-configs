# Shared home-manager config: shell, git, theming, apps
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./vscode.nix
    ./firefox.nix
    ./librewolf.nix
    ./neovim.nix
    ./rofi.nix
    ./hyprland
    ./waybar
  ];

  home = {
    username = "nicola";
    homeDirectory = "/home/nicola";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Browsers
      zen-browser
      google-chrome

      # Media players
      mpv
      jellyfin-media-player

      # File management
      dolphin
      peazip

      # Networking / remote
      netbird
      rustdesk

      # Graphics
      inkscape

      # Communication
      signal-desktop
      telegram-desktop

      # Recording / streaming
      obs-studio

      # System monitoring
      btop

      # Office
      libreoffice

      # AI coding CLI
      opencode
    ];
  };

  # Syncthing user-level service
  services.syncthing.enable = true;

  gtk.gtk4.theme = null;

  programs.home-manager.enable = true;
}
