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
          "hyprland/window"
        ];
        modules-center = [ "clock" ];
        modules-right =
          (lib.optionals isLaptop [
            "battery"
            "backlight"
          ])
          ++ [
            "pulseaudio"
            "tray"
            "custom/notification"
            "custom/power-menu"
          ];

        "hyprland/workspaces" = {
          format = "{icon}";
          on-click = "activate";
          sort-by-number = true;
        };

        "hyprland/window" = {
          max-length = 50;
          separate-outputs = true;
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

        tray = {
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
      }

      #workspaces button.active {
        background-color: @base0D;
        color: @base00;
        border-radius: 8px;
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

      #pulseaudio { color: @base0D; }
      #battery { color: @base0B; }
      #backlight { color: @base0A; }

      #custom-notification {
        padding: 0 8px;
        color: @base05;
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
        color: @base08;
        font-size: 14px;
      }
    '';
  };
}
