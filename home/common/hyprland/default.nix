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

  recordingFile = "/tmp/screenrecord-filename";
  recordingPid = "/tmp/screenrecord-pid";

  stopRecording = pkgs.writeShellApplication {
    name = "stop-recording";
    runtimeInputs = [
      pkgs.libnotify
      pkgs.ffmpeg
    ];
    text = ''
      PID_FILE="${recordingPid}"

      if [[ ! -f "$PID_FILE" ]]; then
        exit 0
      fi

      pid=$(cat "$PID_FILE")

      if ! kill -0 "$pid" 2>/dev/null; then
        rm -f "$PID_FILE" "${recordingFile}"
        exit 0
      fi

      # SIGINT is required for gpu-screen-recorder to save the file properly
      kill -SIGINT "$pid" 2>/dev/null || true

      # Wait up to 5 seconds for graceful shutdown
      count=0
      while kill -0 "$pid" 2>/dev/null && (( count < 50 )); do
        sleep 0.1
        count=$((count + 1))
      done

      if kill -0 "$pid" 2>/dev/null; then
        kill -9 "$pid" 2>/dev/null || true
        notify-send "Screen Recording" "Error: force-killed. Video may be corrupted." -u critical -t 5000
      else
        filename=$(cat "${recordingFile}" 2>/dev/null || true)
        if [[ -n "$filename" && -f "$filename" ]]; then
          trimmed="''${filename%.mp4}-trimmed.mp4"
          if ffmpeg -y -ss 0.1 -i "$filename" -c copy "$trimmed" -loglevel quiet 2>/dev/null; then
            mv "$trimmed" "$filename" 2>/dev/null || true
          fi
          rm -f "$trimmed" 2>/dev/null || true
          notify-send "Screen Recording" "Saved: $filename" -t 5000
        fi
      fi
      rm -f "${recordingFile}" "$PID_FILE"
    '';
  };

  toggleRecording = pkgs.writeShellApplication {
    name = "toggle-recording";
    runtimeInputs = [
      pkgs.gpu-screen-recorder
      pkgs.libnotify
    ];
    text = ''
      PID_FILE="${recordingPid}"

      # If PID file exists and process is alive → stop
      if [[ -f "$PID_FILE" ]] && kill -0 "$(cat "$PID_FILE")" 2>/dev/null; then
        exec stop-recording
      fi

      # Clean up stale state and start fresh
      rm -f "$PID_FILE" "${recordingFile}"
      mkdir -p "$HOME/Videos"
      FILE="$HOME/Videos/screenrecording-$(date +'%Y-%m-%d_%H-%M-%S').mp4"
      notify-send "Screen Recording" "Select area to record…" -t 3000

      gpu-screen-recorder -w portal -k auto -s 0x0 -f 60 -fm cfr -fallback-cpu-encoding yes \
        -a default_output -ac aac -o "$FILE" &
      pid=$!

      # Write PID immediately so the shell picks it up during portal selection
      echo "$pid" > "$PID_FILE"

      # Wait for recording to actually start (output file appears after portal selection)
      while kill -0 "$pid" 2>/dev/null && [[ ! -f "$FILE" ]]; do
        sleep 0.2
      done

      if kill -0 "$pid" 2>/dev/null; then
        echo "$FILE" > "${recordingFile}"
        notify-send "Screen Recording" "Recording started" -t 2000
      else
        # Process died (user cancelled portal or error) — clean up
        rm -f "$PID_FILE" "${recordingFile}"
      fi
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

  # Import home-manager session variables into the UWSM-managed Hyprland
  # session. Recommended by the Hyprland wiki for the NixOS + UWSM setup so
  # that PATH and the rest of home.sessionVariables are present inside the
  # session (uwsm sources ~/.config/uwsm/env on start).
  # https://wiki.hypr.land/Nix/Hyprland-on-Home-Manager/#nixos-uwsm
  xdg.configFile."uwsm/env".source =
    "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

  wayland.windowManager.hyprland = {
    enable = true;
    package = null;
    portalPackage = null;
    systemd.enable = false; # Required with UWSM
    configType = "hyprlang";

    settings = {
      "$mod" = "SUPER";
      "$terminal" = "kitty";
      "$menu" = "qs -c mdo ipc call launcher open";

      monitor =
        if isLaptop then
          [ ", preferred, auto, 1" ]
        else
          [
            # Do NOT force a refresh rate (e.g. 2560x1440@144): on this monitor
            # the forced @144 modeline fails DRM scanout, leaving Hyprland alive
            # but rendering a black screen. "preferred" lets Aquamarine use the
            # monitor's advertised preferred mode, which scanout commits cleanly.
            "DP-1, preferred, auto, 1"
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
        "qs -c mdo"
        "wl-paste --type text --watch cliphist store"
        "wl-paste --type image --watch cliphist store"
        "hypridle"
        # nixpkgs hyprpolkitagent installs no bin/ — the binary lives in libexec,
        # so the bare name is not on PATH. Absolute path required.
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      bind = [
        "$mod, Return, exec, $terminal"
        "$mod, D, exec, $menu"
        "$mod, I, exec, qs -c mdo ipc call keybinds open"
        "$mod, Q, killactive,"
        "$mod, V, togglefloating,"
        "$mod, SPACE, togglefloating,"
        "$mod, F, fullscreen,"
        # "$mod, S, layoutmsg, togglesplit"
        "$mod, E, exec, dolphin"
        "$mod, P, exec, zen-beta"
        "$mod, C, exec, code"
        "$mod, B, exec, qs -c mdo ipc call power open"
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
        "$mod SHIFT, S, exec, qs -c mdo ipc call screenshot open"
        # Screenshot — full screen to clipboard
        ", Print, exec, grimblast copy screen"

        # Clipboard history
        "$mod SHIFT, V, exec, qs -c mdo ipc call clipboard open"

        # Emoji picker
        "$mod SHIFT, SPACE, exec, qs -c mdo ipc call emoji open"

        # Screen recording toggle
        "$mod SHIFT, R, exec, toggle-recording"

        # Power menu
        "$mod SHIFT, Escape, exec, qs -c mdo ipc call power open"

        # Toggle notification center
        "$mod, N, exec, qs -c mdo ipc call notifications center"
      ];

      bindm = [
        "$mod, mouse:272, movewindow"
        "$mod, mouse:273, resizewindow"
      ];
    };

    extraConfig = ''
      windowrule = float on, match:initial_title WebcamOverlay
      windowrule = pin on, match:initial_title WebcamOverlay
      windowrule = move (monitor_w-window_w-20) (monitor_h-window_h-20), match:initial_title WebcamOverlay
    '';
  };

  home.packages = with pkgs; [
    hyprpaper
    hyprpicker
    grimblast
    satty
    slurp
    gpu-screen-recorder
    libnotify
    wl-clipboard
    cliphist
    hypridle
    stopRecording
    toggleRecording
  ];
}
