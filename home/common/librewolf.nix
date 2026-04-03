# LibreWolf browser — userChrome from Stylix palette, mirrors firefox.nix
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  stylix.targets.librewolf.profileNames = [ "default" ];

  programs.librewolf = {
    enable = true;
    profiles.default = {
      isDefault = true;

      settings = {
        "toolkit.legacyUserProfileCustomizations.stylesheets" = true;
        "browser.compactmode.show" = true;
        "browser.uidensity" = 1;
      };

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        onepassword-password-manager
        darkreader
      ];

      userChrome = ''
        /* Material Deep Ocean — generated from Stylix palette */
        :root {
          --toolbar-bgcolor: ${c.base00} !important;
          --tab-selected-bgcolor: ${c.base02} !important;
          --urlbar-background-color: ${c.base01} !important;
        }

        #nav-bar {
          background-color: ${c.base00} !important;
          border-bottom: 1px solid ${c.base02} !important;
        }

        #TabsToolbar {
          background-color: ${c.base00} !important;
        }

        .tab-background[selected="true"] {
          background-color: ${c.base02} !important;
        }

        .tabbrowser-tab .tab-label {
          color: ${c.base05} !important;
        }

        #urlbar {
          background-color: ${c.base01} !important;
          border: 1px solid ${c.base0D} !important;
          color: ${c.base05} !important;
        }

        #sidebar-box {
          background-color: ${c.base00} !important;
        }
      '';

      userContent = ''
        * {
          scrollbar-color: ${c.base03} ${c.base01} !important;
        }
      '';
    };
  };
}
