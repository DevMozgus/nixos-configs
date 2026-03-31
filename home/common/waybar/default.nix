# Waybar config: bar layout, modules, conditional laptop widgets
{ lib, isLaptop, ... }:
{
  programs.waybar = {
    enable = true;

    settings = [{
      layer = "top";
      position = "top";
      height = 32;

      modules-left = [ "hyprland/workspaces" "hyprland/window" ];
      modules-center = [ "clock" ];
      modules-right =
        (lib.optionals isLaptop [ "battery" "backlight" "network" ])
        ++ [ "pulseaudio" "cpu" "memory" "tray" ];

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
        format = "{:%A %d %B  %H:%M}";
        tooltip-format = "<tt>{calendar}</tt>";
      };

      battery = {
        states = {
          warning = 30;
          critical = 15;
        };
        format = "{icon} {capacity}%";
        format-charging = "󱐋 {capacity}%";
        format-icons = [ "󰁺" "󰁻" "󰁼" "󰁽" "󰁾" "󰁿" "󰂀" "󰂁" "󰂂" "󰁹" ];
      };

      backlight = {
        format = "󰃟 {percent}%";
        on-scroll-up = "brightnessctl set +5%";
        on-scroll-down = "brightnessctl set 5%-";
      };

      network = {
        format-wifi = "󰖩 {signalStrength}%";
        format-ethernet = "󰈀 {ipaddr}";
        format-disconnected = "󰖪 Disconnected";
        tooltip-format = "{ifname}: {ipaddr}/{cidr}";
      };

      pulseaudio = {
        format = "{icon} {volume}%";
        format-muted = "󰝟 Muted";
        format-icons = {
          default = [ "󰕿" "󰖀" "󰕾" ];
        };
        on-click = "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
      };

      cpu = {
        format = "󰻠 {usage}%";
        interval = 5;
      };

      memory = {
        format = "󰍛 {used:0.1f}G";
        interval = 5;
      };

      tray = {
        spacing = 8;
      };
    }];

    style = lib.mkAfter ''
      /* Waybar overrides — applied after Stylix CSS */
      #workspaces button.active {
        background-color: @base0D;
        color: @base00;
        border-radius: 8px;
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

      #clock, #battery, #cpu, #memory, #network, #pulseaudio, #backlight, #tray {
        padding: 0 8px;
      }
    '';
  };
}
