# Quickshell shell ("mdo") — package, QML deployment, generated theme file
{
  config,
  lib,
  pkgs,
  inputs,
  isLaptop,
  ...
}:
{
  home.packages = [ inputs.quickshell.packages.${pkgs.system}.default ];

  # Deploy the shell QML sources into ~/.config/quickshell/mdo
  xdg.configFile."quickshell/mdo" = {
    source = ./qml;
    recursive = true;
  };

  # Theme file read by the QML at runtime: Stylix palette, fonts and layout
  # flag. Generated at build time so the shell stays in sync with Stylix
  # without hard-coding hex values in QML.
  xdg.configFile."quickshell/mdo/Theme.json".text = builtins.toJSON {
    isLaptop = isLaptop;
    barHeight = 36;
    fonts = {
      monospace = config.stylix.fonts.monospace.name;
      sansSerif = config.stylix.fonts.sansSerif.name;
    };
    colors = config.lib.stylix.colors.withHashtag;
  };
}
