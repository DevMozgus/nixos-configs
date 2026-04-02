# Laptop-specific Hyprland: touchpad, gestures, lid-switch monitor toggle
{ ... }:
{
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

    bindl = [
      # Lid switch — disable laptop monitor when closed
      ", switch:on:Lid Switch, exec, hyprctl keyword monitor \"eDP-1, disable\""
      ", switch:off:Lid Switch, exec, hyprctl keyword monitor \"eDP-1, preferred, auto, 1\""
    ];
  };
}
