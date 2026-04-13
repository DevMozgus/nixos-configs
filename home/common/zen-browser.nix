# Zen browser — installed via HM module with Stylix auto-theming
{ pkgs, ... }:
{
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      isDefault = true;

      extensions.packages = with pkgs.nur.repos.rycee.firefox-addons; [
        ublock-origin
        onepassword-password-manager
        darkreader
        sponsorblock
        wappalyzer
        tampermonkey
        boring-rss
        untrap-for-youtube
        imagus
      ];
    };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };
}
