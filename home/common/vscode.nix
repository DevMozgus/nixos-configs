# VSCodium + nix-vscode-extensions overlay + Stylix colorCustomizations
{ pkgs, config, lib, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscode;
    mutableExtensionsDir = false;

    userArgv = {
      "password-store" = "gnome-libsecret";
    };

    profiles.default = {
      extensions = with pkgs.vscode-marketplace; [
        jnoortheen.nix-ide
        vscodevim.vim
        ms-python.python
        eamodio.gitlens
        esbenp.prettier-vscode
        dbaeumer.vscode-eslint
      ];

      userSettings = {
        "editor.fontSize" = lib.mkForce 14;
        "editor.formatOnSave" = true;
        "editor.lineHeight" = 1.6;
        "editor.minimap.enabled" = false;
        "workbench.colorTheme" = "Stylix";

        "workbench.colorCustomizations" = {
          "[Stylix]" = let
            c = config.lib.stylix.colors.withHashtag;
          in {
            "editorLineNumber.activeForeground" = c.base0D;
            "editorCursor.foreground" = c.base0E;
          };
        };

        "nix.enableLanguageServer" = true;
        "nix.serverPath" = "nil";
      };
    };
  };
}
