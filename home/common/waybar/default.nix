# Waybar config: bar layout, modules, conditional laptop widgets
{ lib, isLaptop, ... }:
{
  programs.waybar = {
    enable = true;

    settings = [
      {
        layer = "top";
        position = "top";
        height = 32;
        margin-left = 10;
        margin-right = 10;

        modules-left = [
          "hyprland/workspaces"
        ];
        modules-center = [ "clock" ];
        modules-right =
          (lib.optionals isLaptop [
            "battery"
            "backlight"
          ])
          ++ [
            "pulseaudio"
            "pulseaudio#microphone"
            "custom/recording"
            "tray"
            "custom/notification"
            "custom/power-menu"
          ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
          persistent-workspaces = {
            "*" = [
              1
              2
              3
              4
              5
            ];
          };
        };

        clock = {
          format = "{:%H:%M}";
          tooltip-format = "<tt>{calendar}</tt>";
        };

        battery = {
          states = {
            warning = 30;
            critical = 15;
          };
          format = "{icon} {capacity}%";
          format-charging = "󱐋 {capacity}%";
          format-icons = [
            "󰁺"
            "󰁻"
            "󰁼"
            "󰁽"
            "󰁾"
            "󰁿"
            "󰂀"
            "󰂁"
            "󰂂"
            "󰁹"
          ];
        };

        backlight = {
          format = "󰃟 {percent}%";
          on-scroll-up = "brightnessctl set +5%";
          on-scroll-down = "brightnessctl set 5%-";
        };

        pulseaudio = {
          format = "{icon} {volume}%";
          format-muted = "󰝟 Muted";
          format-icons = {
            default = [
              "󰕿"
              "󰖀"
              "󰕾"
            ];
          };
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        };

        "pulseaudio#microphone" = {
          format = "{format_source}";
          format-source = "󰍬 {volume}%";
          format-source-muted = "󰍭";
          on-click = "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
        };

        tray = {
          icon-size = 16;
          spacing = 8;
        };

        "custom/notification" = {
          tooltip = true;
          tooltip-format = "Notifications";
          format = "{icon}";
          format-icons = {
            notification = "󱅫";
            none = "󰂜";
            dnd-notification = "󰂛";
            dnd-none = "󰂜";
            inhibited-notification = "󱅫";
            inhibited-none = "󰂜";
            dnd-inhibited-notification = "󰂛";
            dnd-inhibited-none = "󰂜";
          };
          return-type = "json";
          exec-if = "which swaync-client";
          exec = "swaync-client -swb";
          on-click = "swaync-client -t -sw";
          on-click-right = "swaync-client -d -sw";
          escape = true;
        };

        "custom/recording" = {
          exec = "echo '󰑊 REC'";
          exec-if = "pgrep -x wf-recorder";
          interval = 1;
          format = "{}";
          tooltip = true;
          tooltip-format = "Recording — click to stop";
          on-click = "pkill -INT wf-recorder";
        };

        "custom/power-menu" = {
          tooltip = true;
          tooltip-format = "Power menu";
          format = "󰐥";
          on-click = "power-menu";
        };
      }
    ];

    style = lib.mkAfter ''
      /* Waybar overrides — applied after Stylix CSS */
      #workspaces button {
        margin: 4px 2px;
        padding: 0 6px;
        border-bottom: 2px solid transparent;
      }

      #workspaces button.active {
        background-color: transparent;
        color: @base06;
        border-radius: 0;
        border-bottom: 2px solid @base0D;
        margin: 4px 2px;
        padding: 0 6px;
      }

      #battery.critical {
        color: @base08;
      }

      #battery.warning {
        color: @base09;
      }

      #waybar {
        font-family: "JetBrainsMono Nerd Font";
        font-size: 13px;
      }

      #clock, #battery, #pulseaudio, #backlight, #tray {
        padding: 0 8px;
      }

      #pulseaudio { color: @base04; font-size: 16px; }
      #pulseaudio.microphone { color: @base04; font-size: 16px; padding: 0 8px; }
      #pulseaudio.microphone.source-muted { color: @base03; }
      #battery { color: @base0B; font-size: 16px; }
      #backlight { color: @base04; font-size: 16px; }

      .sn-button {
        padding: 0 4px;
        color: @base04;
      }

      #custom-recording {
        padding: 0 8px;
        color: @base08;
        font-size: 16px;
        animation: blink 1s step-start infinite;
      }

      @keyframes blink {
        50% { opacity: 0.3; }
      }

      #custom-notification {
        padding: 0 8px;
        color: @base05;
        font-size: 16px;
      }

      #custom-notification.dnd-none,
      #custom-notification.inhibited-none,
      #custom-notification.dnd-inhibited-none {
        color: @base03;
      }

      #custom-notification.notification,
      #custom-notification.dnd-notification,
      #custom-notification.inhibited-notification,
      #custom-notification.dnd-inhibited-notification {
        color: @base0D;
      }

      #custom-power-menu {
        padding: 0 10px 0 6px;
        color: @base04;
        font-size: 16px;
      }
    '';
  };
}
