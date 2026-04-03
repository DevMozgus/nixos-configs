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
    ./zen-browser.nix
    ./neovim.nix
    ./rofi.nix
    ./storage.nix
    ./hyprland
    ./waybar
  ];

  home = {
    username = "nicola";
    homeDirectory = "/home/nicola";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Browsers
      google-chrome

      # Media players
      mpv
      jellyfin-media-player
      jellyfin-tui

      # File management
      kdePackages.dolphin
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

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";
      "inode/directory" = "org.kde.dolphin.desktop";
      "x-scheme-handler/file" = "org.kde.dolphin.desktop";
      "text/plain" = "nvim.desktop";
      "x-scheme-handler/terminal" = "kitty.desktop";
    };
  };

  programs.home-manager.enable = true;
}
