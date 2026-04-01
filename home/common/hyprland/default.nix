# Hyprland shared config: keybindings, animations, rules, exec-once
{ pkgs, isLaptop, ... }:
let
  showHyprKeybindings = pkgs.writeShellApplication {
    name = "show-hypr-keybindings";
    runtimeInputs = [ pkgs.jq pkgs.rofi ];
    text = ''
      hyprctl binds -j | jq -r '
        def mods:
          . as $m |
          [ if (($m / 64 | floor) % 2) == 1 then "SUPER" else empty end,
            if (($m / 8  | floor) % 2) == 1 then "ALT"   else empty end,
            if (($m / 4  | floor) % 2) == 1 then "CTRL"  else empty end,
            if (($m / 1  | floor) % 2) == 1 then "SHIFT" else empty end
          ];
        .[] | select(.mouse == false) |
        ((.modmask | mods) + [.key] | join("+")) +
        "  \u2192  " +
        .dispatcher +
        (if .arg != "" then " " + .arg else "" end)
      ' | sort | rofi -dmenu -i -p "Keybindings"
    '';
  };
in
{
  imports = [ ]
    ++ (if isLaptop then [ ./laptop.nix ] else [ ]);

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false; # Required with UWSM

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";

      monitor = if isLaptop
        then [ ", preferred, auto, 1" ]
        else [ "DP-1, 2560x1440@144, 0x0, 1" ", preferred, auto, 1" ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        layout = "dwindle";
      };

      decoration = {
        rounding = 10;
        blur = {
          enabled = true;
          size = 5;
          passes = 3;
          new_optimizations = true;
        };
        shadow = {
          enabled = true;
          range = 8;
          render_power = 2;
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint, 0.23, 1, 0.32, 1"
          "easeInOutCubic, 0.65, 0, 0.35, 1"
        ];
        animation = [
          "windows, 1, 5, easeOutQuint"
          "windowsOut, 1, 5, easeOutQuint, popin 80%"
          "fade, 1, 4, easeOutQuint"
          "workspaces, 1, 4, easeInOutCubic, slide"
        ];
      };

      dwindle = {
        pseudotile = true;
        preserve_split = true;
      };

      input = {
        kb_layout = "us";
        follow_mouse = 1;
      };

      exec-once = [
        "waybar"
        "swaync"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, H, exec, show-hypr-keybindings"
        "$mod, Q, killactive,"
        "$mod, M, exit,"
        "$mod, V, togglefloating,"
        "$mod, F, fullscreen,"
        "$mod, P, pseudo,"
        "$mod, S, togglesplit,"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"

        # Workspaces
        "$mod, 1, workspace, 1"
        "$mod, 2, workspace, 2"
        "$mod, 3, workspace, 3"
        "$mod, 4, workspace, 4"
        "$mod, 5, workspace, 5"
        "$mod, 6, workspace, 6"
        "$mod, 7, workspace, 7"
        "$mod, 8, workspace, 8"
        "$mod, 9, workspace, 9"
        "$mod, 0, workspace, 10"

        # Move to workspace
        "$mod SHIFT, 1, movetoworkspace, 1"
        "$mod SHIFT, 2, movetoworkspace, 2"
        "$mod SHIFT, 3, movetoworkspace, 3"
        "$mod SHIFT, 4, movetoworkspace, 4"
        "$mod SHIFT, 5, movetoworkspace, 5"
        "$mod SHIFT, 6, movetoworkspace, 6"
        "$mod SHIFT, 7, movetoworkspace, 7"
        "$mod SHIFT, 8, movetoworkspace, 8"
        "$mod SHIFT, 9, movetoworkspace, 9"
        "$mod SHIFT, 0, movetoworkspace, 10"

        # Screenshot
        "$mod SHIFT, S, exec, grimblast copy area"

        # Clipboard history
        "$mod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # Lock
        "$mod SHIFT, L, exec, hyprlock"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };
  };

  home.packages = with pkgs; [
    grimblast
    wl-clipboard
    cliphist
    hypridle
    hyprlock
    swaynotificationcenter
    showHyprKeybindings
  ];
}
