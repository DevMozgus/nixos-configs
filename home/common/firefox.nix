# Firefox profile + userChrome.css from Stylix palette + extensions
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  stylix.targets.firefox.profileNames = [ "default" ];

  programs.firefox = {
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
        bitwarden
        darkreader
      ];

      userChrome = ''
        /* Material Deep Ocean — generated from Stylix palette */
        :root {
          --toolbar-bgcolor: ${c.base00} !important;
          --tab-selected-bgcolor: ${c.base02} !important;
          --urlbar-background-color: ${c.base01} !important;
        }

        /* Navigation bar */
        #nav-bar {
          background-color: ${c.base00} !important;
          border-bottom: 1px solid ${c.base02} !important;
        }

        /* Tabs toolbar */
        #TabsToolbar {
          background-color: ${c.base00} !important;
        }

        /* Active tab */
        .tab-background[selected="true"] {
          background-color: ${c.base02} !important;
        }

        /* Tab labels */
        .tabbrowser-tab .tab-label {
          color: ${c.base05} !important;
        }

        /* URL bar */
        #urlbar {
          background-color: ${c.base01} !important;
          border: 1px solid ${c.base0D} !important;
          color: ${c.base05} !important;
        }

        /* Sidebar */
        #sidebar-box {
          background-color: ${c.base00} !important;
        }
      '';

      userContent = ''
        /* Scrollbar theming */
        * {
          scrollbar-color: ${c.base03} ${c.base01} !important;
        }
      '';
    };
  };
}
