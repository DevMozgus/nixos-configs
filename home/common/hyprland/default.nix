# Hyprland shared config: keybindings, animations, rules, exec-once
{
  pkgs,
  config,
  lib,
  isLaptop,
  ...
}:
let
  c = config.lib.stylix.colors;
  wallpaper = ../../../assets/wallpaper3.png;

  powerMenu = pkgs.writeShellApplication {
    name = "power-menu";
    runtimeInputs = [
      pkgs.rofi
    ];
    text = ''
      CHOSEN=$(printf '%s\n' "󰌾" "󰒲" "󰍃" "󰑐" "󰐥" \
        | rofi -dmenu \
            -theme "$HOME/.config/rofi/powermenu-theme.rasi" \
            -p "")

      case "$CHOSEN" in
        "󰌾")  hyprlock ;;
        "󰒲")  systemctl suspend ;;
        "󰍃")  hyprctl dispatch exit ;;
        "󰑐")  systemctl reboot ;;
        "󰐥")  systemctl poweroff ;;
      esac
    '';
  };

  showHyprKeybindings = pkgs.writeShellApplication {
    name = "show-hypr-keybindings";
    runtimeInputs = [ pkgs.rofi ];
    text = ''
      hdr() { printf '<span foreground="#${c.base0A}" weight="bold">  ── %s ──────────────────────────────────────────────</span>\n' "$1"; }
      kb()  { printf '  %-28s  %s\n' "$1" "$2"; }

      {
        hdr "Apps"
        kb "SUPER + Return"           "Terminal (Kitty)"
        kb "SUPER + D"                "App Launcher (Rofi)"
        kb "SUPER + E"                "File Manager (Dolphin)"
        kb "SUPER + P"                "Browser (Zen)"
        kb "SUPER + C"                "Code Editor (VSCode)"
        kb "SUPER + M"                "Media Player (Jellyfin TUI)"
        echo ""
        hdr "Window Management"
        kb "SUPER + Q"                "Close Window"
        kb "SUPER + V  /  SPACE"      "Toggle Floating"
        kb "SUPER + F"                "Fullscreen"
        kb "SUPER + S"                "Toggle Split"
        echo ""
        hdr "Focus & Navigation"
        kb "SUPER + ←/→/↑/↓"         "Move Focus"
        kb "SUPER + J  /  K"          "Cycle Focus (Next / Prev)"
        kb "SUPER + SHIFT + J  /  K"  "Swap Windows (Next / Prev)"
        echo ""
        hdr "Resize"
        kb "SUPER + H  /  L"          "Resize Horizontal (−100 / +100)"
        kb "SUPER + SHIFT + H  /  L"  "Resize Vertical (−100 / +100)"
        echo ""
        hdr "Workspaces"
        kb "SUPER + 1–0"              "Switch to Workspace 1–10"
        kb "SUPER + SHIFT + 1–0"      "Move Window to Workspace 1–10"
        echo ""
        hdr "Mouse"
        kb "SUPER + LMB drag"         "Move Window"
        kb "SUPER + RMB drag"         "Resize Window"
        echo ""
        hdr "Screenshot & Recording"
        kb "SUPER + S"                "Screenshot Region → Clipboard"
        kb "SUPER + SHIFT + S"        "Screenshot / Recording Menu"
        kb "Print"                    "Screenshot Screen → Clipboard"
        kb "SUPER + SHIFT + R"        "Toggle Screen Recording"
        echo ""
        hdr "Clipboard & Notifications"
        kb "SUPER + SHIFT + V"        "Clipboard History (cliphist)"
        kb "SUPER + SHIFT + SPACE"     "Emoji Picker"
        kb "SUPER + N"                "Notification Center (SwayNC)"
        echo ""
        hdr "Media Keys (Laptop)"
        kb "XF86AudioRaiseVolume"     "Volume Up (+5%)"
        kb "XF86AudioLowerVolume"     "Volume Down (−5%)"
        kb "XF86AudioMute"            "Toggle Mute"
        kb "XF86AudioMicMute"         "Toggle Mic Mute"
        kb "XF86MonBrightnessUp"      "Brightness Up (+5%)"
        kb "XF86MonBrightnessDown"    "Brightness Down (−5%)"
        kb "XF86AudioPlay / Pause"    "Play / Pause"
        kb "XF86AudioNext / Prev"     "Next / Previous Track"
        echo ""
        hdr "System"
        kb "SUPER + B"                "Power Menu"
        kb "SUPER + SHIFT + Escape"   "Power Menu"
        kb "SUPER + I"                "Keybindings Reference (this menu)"
      } | rofi -dmenu -markup-rows \
            -theme "$HOME/.config/rofi/keybindings-theme.rasi" \
            -p "󰌌  Keybindings" || true
    '';
  };

  emojiPicker = pkgs.writeShellApplication {
    name = "emoji-picker";
    runtimeInputs = [
      pkgs.rofimoji
      pkgs.rofi
      pkgs.wl-clipboard
    ];
    text = ''
      rofimoji \
        --action copy \
        --selector-args "--theme $HOME/.config/rofi/emoji-theme.rasi"
    '';
  };

  toggleRecording = pkgs.writeShellApplication {
    name = "toggle-recording";
    runtimeInputs = [
      pkgs.wf-recorder
      pkgs.libnotify
      pkgs.pulseaudio
    ];
    text = ''
      if pgrep -x wf-recorder > /dev/null; then
        pkill -INT wf-recorder
        notify-send "Screen Recording" "Recording stopped"
      else
        mkdir -p "$HOME/Videos"
        FILE="$HOME/Videos/$(date +%Y%m%d_%H%M%S).mp4"
        AUDIO_DEVICE="$(pactl get-default-sink).monitor"
        notify-send "Screen Recording" "Recording started — $FILE"
        wf-recorder --audio-device "$AUDIO_DEVICE" -f "$FILE"
      fi
    '';
  };

  screenshotMenu = pkgs.writeShellApplication {
    name = "screenshot-menu";
    runtimeInputs = [
      pkgs.rofi
      pkgs.grimblast
      pkgs.satty
      pkgs.wf-recorder
      pkgs.slurp
      pkgs.wl-clipboard
      pkgs.libnotify
      pkgs.mpv
      pkgs.hyprpicker
      pkgs.pulseaudio
    ];
    text = ''
      CHOSEN=$(printf '%s\n' \
        "󰹑  Screenshot Screen" \
        "󰹑  Screenshot Region" \
        "󰕧  Record Region" \
        "󰕧  Record Screen" \
        "󰕧  Record Screen + Audio" \
        "󰕧  Record + Webcam" \
        "󰈠  Color Picker" \
        | rofi -dmenu -p "")

      case "$CHOSEN" in
        "󰹑  Screenshot Screen")
          grimblast save screen - | satty --filename - ;;
        "󰹑  Screenshot Region")
          grimblast save area - | satty --filename - ;;
        "󰕧  Record Region")
          GEOM=$(slurp)
          mkdir -p "$HOME/Videos"
          FILE="$HOME/Videos/$(date +%Y%m%d_%H%M%S).mp4"
          notify-send "Screen Recording" "Recording region…"
          wf-recorder -g "$GEOM" -f "$FILE"
          wl-copy < "$FILE"
          notify-send "Screen Recording" "Saved and copied: $FILE" ;;
        "󰕧  Record Screen")
          mkdir -p "$HOME/Videos"
          FILE="$HOME/Videos/$(date +%Y%m%d_%H%M%S).mp4"
          notify-send "Screen Recording" "Recording screen…"
          wf-recorder -f "$FILE"
          wl-copy < "$FILE"
          notify-send "Screen Recording" "Saved and copied: $FILE" ;;
        "󰕧  Record Screen + Audio")
          mkdir -p "$HOME/Videos"
          FILE="$HOME/Videos/$(date +%Y%m%d_%H%M%S).mp4"
          AUDIO_DEVICE="$(pactl get-default-sink).monitor"
          notify-send "Screen Recording" "Recording with audio…"
          wf-recorder --audio-device "$AUDIO_DEVICE" -f "$FILE"
          wl-copy < "$FILE"
          notify-send "Screen Recording" "Saved and copied: $FILE" ;;
        "󰕧  Record + Webcam")
          mkdir -p "$HOME/Videos"
          FILE="$HOME/Videos/$(date +%Y%m%d_%H%M%S).mp4"
          AUDIO_DEVICE="$(pactl get-default-sink).monitor"
          notify-send "Screen Recording" "Recording with audio + webcam…"
          mpv --title="webcam" --no-border --autofit=320 /dev/video0 &
          wf-recorder --audio-device "$AUDIO_DEVICE" -f "$FILE"
          wl-copy < "$FILE"
          notify-send "Screen Recording" "Saved and copied: $FILE" ;;
        "󰈠  Color Picker")
          hyprpicker -a ;;
      esac
    '';
  };
in
{
  imports = [ ./hyprlock.nix ] ++ (if isLaptop then [ ./laptop.nix ] else [ ]);

  services.hyprpaper = {
    enable = true;
    settings = {
      preload = [ "${wallpaper}" ];
      wallpaper = [ ",${wallpaper}" ];
      splash = false;
    };
  };

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false; # Required with UWSM

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "rofi -show drun";

      monitor =
        if isLaptop then
          [ ", preferred, auto, 1" ]
        else
          [
            "DP-1, 2560x1440@144, 0x0, 1"
            ", preferred, auto, 1"
          ];

      general = {
        gaps_in = 5;
        gaps_out = 10;
        border_size = 2;
        "col.active_border" = lib.mkForce "rgba(${c.base04}77)";
        "col.inactive_border" = lib.mkForce "rgba(${c.base03}44)";
        resize_on_border = false;
        allow_tearing = false;
        layout = "dwindle";
      };

      decoration = {
        rounding = 0;
        blur = {
          enabled = true;
          size = 2;
          passes = 2;
          special = true;
          brightness = 0.60;
          contrast = 0.75;
        };
        shadow = {
          enabled = true;
          range = 2;
          render_power = 3;
          color = lib.mkForce "rgba(1a1a1aee)";
        };
      };

      animations = {
        enabled = true;
        bezier = [
          "easeOutQuint,0.23,1,0.32,1"
          "easeInOutCubic,0.65,0.05,0.36,1"
          "linear,0,0,1,1"
          "almostLinear,0.5,0.5,0.75,1.0"
          "quick,0.15,0,0.1,1"
        ];
        animation = [
          "global, 1, 6, default"
          "border, 1, 3.5, easeOutQuint"
          "windows, 1, 3.0, easeOutQuint"
          "windowsIn, 1, 2.5, easeOutQuint, popin 87%"
          "windowsOut, 1, 1.0, linear, popin 87%"
          "fadeIn, 1, 1.2, almostLinear"
          "fadeOut, 1, 1.0, almostLinear"
          "fade, 1, 2.0, quick"
          "layers, 1, 2.5, easeOutQuint"
          "layersIn, 1, 2.5, easeOutQuint, fade"
          "layersOut, 1, 1.0, linear, fade"
          "fadeLayersIn, 1, 1.2, almostLinear"
          "fadeLayersOut, 1, 0.9, almostLinear"
          "workspaces, 0, 0, ease"
          "specialWorkspace, 1, 2.5, easeOutQuint, slidevert"
        ];
      };

      # No border when workspace has only one window
      workspace = [
        "w[1], border:0"
      ];

      dwindle = {
        pseudotile = true;
        preserve_split = true;
        force_split = 2;
      };

      misc = {
        disable_hyprland_logo = true;
        disable_splash_rendering = true;
        focus_on_activate = true;
        anr_missed_pings = 3;
        on_focus_under_fullscreen = 1;
      };

      cursor = {
        hide_on_key_press = true;
        warp_on_change_workspace = 1;
      };

      binds = {
        hide_special_on_workspace_change = true;
      };

      input = {
        kb_layout = "us";
        kb_options = "caps:escape";
        follow_mouse = 1;
      };

      exec-once = [
        "dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP"
        "waybar"
        "swaync"
        "nm-applet --indicator"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, I, exec, show-hypr-keybindings"
        "$mod, Q, killactive,"
        "$mod, V, togglefloating,"
        "$mod, SPACE, togglefloating,"
        "$mod, F, fullscreen,"
        "$mod, S, togglesplit,"
        "$mod, E, exec, dolphin"
        "$mod, P, exec, zen-beta"
        "$mod, C, exec, code"
        "$mod, B, exec, power-menu"
        "$mod, M, exec, kitty -e jellyfin-tui"

        # Move focus
        "$mod, left, movefocus, l"
        "$mod, right, movefocus, r"
        "$mod, up, movefocus, u"
        "$mod, down, movefocus, d"
        "$mod, J, cyclenext,"
        "$mod, K, cyclenext, prev"

        # Resize window
        "$mod, H, resizeactive, -100 0"
        "$mod, L, resizeactive, 100 0"
        "$mod SHIFT, H, resizeactive, 0 -100"
        "$mod SHIFT, L, resizeactive, 0 100"

        # Move window in stack
        "$mod SHIFT, J, swapnext,"
        "$mod SHIFT, K, swapnext, prev"

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

        # Screenshot — region to clipboard
        "$mod, S, exec, grimblast copy area"
        # Screenshot/recording menu
        "$mod SHIFT, S, exec, screenshot-menu"
        # Screenshot — full screen to clipboard
        ", Print, exec, grimblast copy screen"

        # Clipboard history
        "$mod SHIFT, V, exec, cliphist list | rofi -dmenu | cliphist decode | wl-copy"

        # Emoji picker
        "$mod SHIFT, SPACE, exec, emoji-picker"

        # Screen recording toggle
        "$mod SHIFT, R, exec, toggle-recording"

        # Power menu
        "$mod SHIFT, Escape, exec, power-menu"

        # Toggle notification center
        "$mod, N, exec, swaync-client -t -sw"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      windowrule = float on, match:initial_title webcam
      windowrule = pin on, match:initial_title webcam
      windowrule = move (monitor_w-window_w-20) (monitor_h-window_h-20), match:initial_title webcam
    '';
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    grimblast
    satty
    slurp
    wf-recorder
    libnotify
    wl-clipboard
    cliphist
    hypridle
    swaynotificationcenter
    networkmanagerapplet
    showHyprKeybindings
    toggleRecording
    screenshotMenu
    powerMenu
    emojiPicker
  ];
}
