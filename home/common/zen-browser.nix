# Zen browser — installed via HM module with Stylix auto-theming
{ ... }:
{
  programs.zen-browser = {
    enable = true;
    profiles.default = {
      isDefault = true;
    };
  };

  stylix.targets.zen-browser = {
    enable = true;
    profileNames = [ "default" ];
  };
}
