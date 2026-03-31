# Shared home-manager config: shell, git, theming, apps
{ inputs, isLaptop, ... }:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./vscode.nix
    ./firefox.nix
    ./neovim.nix
    ./rofi.nix
    ./hyprland
    ./waybar
  ];

  home = {
    username = "nicola";
    homeDirectory = "/home/nicola";
    stateVersion = "25.05";
  };

  gtk.gtk4.theme = null;

  programs.home-manager.enable = true;
}
