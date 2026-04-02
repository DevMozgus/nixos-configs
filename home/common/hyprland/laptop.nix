# Laptop-specific Hyprland: touchpad, gestures, lid-switch monitor toggle, media keys
{ pkgs, ... }:
{
  home.packages = with pkgs; [
    playerctl
  ];

  wayland.windowManager.hyprland.settings = {
    input = {
      touchpad = {
        natural_scroll = true;
        tap-to-click = true;
        drag_lock = true;
        disable_while_typing = true;
      };
    };

    gestures = {
      workspace_swipe_distance = 300;
      workspace_swipe_cancel_ratio = 0.5;
    };

    "gesture" = [
      "3, horizontal, workspace"
    ];

    # Repeating binds that also work on the lock screen
    bindel = [
      ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
      ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
      ", XF86MonBrightnessUp, exec, brightnessctl set 5%+"
      ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"
    ];

    bindl = [
      # Lid switch — disable laptop monitor when closed
      ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1, disable\""
      ", switch:off:Lid Switch, exec, hyprctl keyword monitor \"eDP-1, preferred, auto, 1\""

      # Audio mute
      ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
      ", XF86AudioMicMute, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

      # Media playback
      ", XF86AudioPlay, exec, playerctl play-pause"
      ", XF86AudioPause, exec, playerctl play-pause"
      ", XF86AudioNext, exec, playerctl next"
      ", XF86AudioPrev, exec, playerctl previous"
    ];
  };
}
