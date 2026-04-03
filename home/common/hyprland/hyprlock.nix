# Hyprlock — lock screen with Material Deep Ocean theme
{ config, lib, ... }:
let
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.monospace.name;
  wallpaper = toString ../../../assets/wallpaper2.png;
in
{
  programs.hyprlock = {
    enable = true;

    settings = {
      general = {
        hide_cursor = true;
        ignore_empty_input = true;
      };

      background = lib.mkForce [
        {
          path = wallpaper;
          blur_passes = 0;
          vibrancy = 0.0;
        }
      ];

      label = lib.mkForce [
        # Time
        {
          text = ''cmd[update:1000] echo "$(date +'%H:%M')"'';
          font_size = 100;
          font_family = "${font} Bold";
          color = "0x${c.base06}E6";
          shadow_passes = 2;
          shadow_size = 4;
          position = "0, -140";
          halign = "center";
          valign = "top";
        }
        # Date
        {
          text = ''cmd[update:60000] echo "$(date +'%A, %B %d')"'';
          font_size = 18;
          font_family = font;
          color = "0x${c.base05}CC";
          shadow_passes = 2;
          shadow_size = 3;
          position = "0, -330";
          halign = "center";
          valign = "top";
        }
        # Username
        {
          text = "  $USER";
          font_size = 14;
          font_family = "${font} Bold";
          color = "0x${c.base05}FF";
          position = "0, 284";
          halign = "center";
          valign = "bottom";
        }
      ];

      input-field = lib.mkForce [
        {
          size = "300, 50";
          rounding = 0;
          outline_thickness = 2;

          dots_spacing = 0.4;
          dots_center = true;

          font_color = "0x${c.base06}E6";
          font_family = font;

          # Border colour: accent blue normally, green on check, red on fail
          outer_color = "0x${c.base04}F2";
          inner_color = "0x${c.base02}88";
          check_color = "0x${c.base0B}F2";
          fail_color = "0x${c.base08}F2";
          capslock_color = "0x${c.base0A}F2";

          hide_input = false;
          fade_on_empty = false;
          placeholder_text = ''<i><span foreground="##${c.base04}">Enter password…</span></i>'';

          fail_text = ''<i><span foreground="##${c.base08}">$FAIL ($ATTEMPTS)</span></i>'';

          position = "0, 200";
          halign = "center";
          valign = "bottom";
        }
      ];

      animation = [ "inputFieldColors, 1, 2, default" ];
    };
  };
}
