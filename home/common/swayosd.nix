# SwayOSD — on-screen display for volume / brightness / lock-keys
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors;
in
{
  home.packages = [ pkgs.swayosd ];

  # Server must run before any client commands
  wayland.windowManager.hyprland.settings = {
    exec-once = [ "swayosd-server" ];

    # Volume + Brightness — bindel: works on lock screen + allows repeat
    bindel = [
      ", XF86AudioRaiseVolume,   exec, swayosd-client --output-volume +5"
      ", XF86AudioLowerVolume,   exec, swayosd-client --output-volume -5"
      ", XF86MonBrightnessUp,    exec, swayosd-client --brightness raise"
      ", XF86MonBrightnessDown,  exec, swayosd-client --brightness lower"
    ];
    bindl = [
      ", XF86AudioMute,          exec, swayosd-client --output-volume mute-toggle"
      ", XF86AudioMicMute,       exec, swayosd-client --input-volume  mute-toggle"
      "$mod, XF86MonBrightnessUp,   exec, swayosd-client --brightness 100"
      "$mod, XF86MonBrightnessDown, exec, swayosd-client --brightness 0"
    ];

    # Lock-key indicators
    bindr = [
      "CAPS,       Caps_Lock,   exec, swayosd-client --caps-lock"
      ",           Scroll_Lock, exec, swayosd-client --scroll-lock"
      ",           Num_Lock,    exec, swayosd-client --num-lock"
    ];
  };

  xdg.configFile."swayosd/config.toml".text = ''
    [server]
    max_volume = 100
    show_percentage = true
  '';

  xdg.configFile."swayosd/style.css".text = ''
    window {
        padding: 0px 10px;
        border-radius: 0px;
        border: 2px solid #${c.base04};
        background: alpha(#${c.base01}, 0.97);
    }

    #container {
        margin: 12px;
    }

    image, label {
        color: #${c.base05};
    }

    progressbar:disabled,
    image:disabled {
        opacity: 0.95;
    }

    progressbar {
        min-height: 6px;
        border-radius: 0px;
        background: transparent;
        border: none;
    }

    trough {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: alpha(#${c.base04}, 0.35);
    }

    progress {
        min-height: inherit;
        border-radius: inherit;
        border: none;
        background: #${c.base0D};
    }
  '';
}
