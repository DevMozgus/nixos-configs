# SwayNotificationCenter — notifications + notification center
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.monospace.name;
in
{
  home.packages = [ pkgs.swaynotificationcenter ];

  xdg.configFile."swaync/config.json".text = builtins.toJSON {
    "$schema" = "/etc/xdg/swaync/configSchema.json";
    "ignore-gtk-theme" = true;
    "positionX" = "right";
    "positionY" = "top";
    "layer" = "overlay";
    "control-center-layer" = "top";
    "layer-shell" = true;
    "cssPriority" = "user";
    "control-center-margin-top" = 10;
    "control-center-margin-bottom" = 10;
    "control-center-margin-right" = 10;
    "control-center-margin-left" = 0;
    "notification-2fa-action" = true;
    "notification-inline-replies" = false;
    "notification-body-image-height" = 100;
    "notification-body-image-width" = 200;
    "notification-icon-size" = 48;
    "timeout" = 8;
    "timeout-low" = 6;
    "timeout-critical" = 0;
    "fit-to-screen" = true;
    "relative-timestamps" = true;
    "control-center-width" = 380;
    "control-center-height" = 600;
    "notification-window-width" = 350;
    "keyboard-shortcuts" = true;
    "notification-grouping" = true;
    "image-visibility" = "when-available";
    "transition-time" = 200;
    "hide-on-clear" = false;
    "hide-on-action" = true;
    "text-empty" = "No Notifications";
    "script-fail-notify" = true;
    "widgets" = [
      "dnd"
      "mpris"
      "notifications"
      "volume"
    ];
    "widget-config" = {
      "dnd" = {
        "text" = "Do Not Disturb";
      };
      "mpris" = {
        "show-album-art" = "always";
        "loop-carousel" = false;
      };
      "volume" = {
        "label" = "󰕾 ";
        "expand-button-label" = "";
        "collapse-button-label" = "";
        "show-per-app" = true;
        "show-per-app-icon" = true;
        "show-per-app-label" = false;
      };
    };
  };

  xdg.configFile."swaync/style.css".text = ''
    :root {
        --bg-primary:        #${c.base00};
        --bg-secondary:      #${c.base01};
        --bg-button:         #${c.base02};
        --bg-button-hover:   #${c.base03};
        --text-primary:      #${c.base05};
        --text-disabled:     #${c.base03};
        --border-color:      #${c.base04};
        --accent:            #${c.base0D};
        --priority-low:      #${c.base05};
        --priority-normal:   #${c.base0C};
        --priority-critical: #${c.base08};
        --transition-standard: 0.15s ease-in-out;
    }

    * { outline: none; }
    *:focus { outline: none; box-shadow: none; }

    scrollbar, scrollbar slider {
        opacity: 0;
        min-width: 0px;
        min-height: 0px;
        background: transparent;
    }

    /* Common button styles */
    .close-button,
    .widget-title > button,
    .widget-dnd switch,
    .widget-menubar > .menu-button-bar > .widget-menubar-container button,
    .widget-menubar > revealer button,
    .widget-inhibitors > button {
        border-radius: 0px;
        border: none;
        box-shadow: none;
        transition: background var(--transition-standard);
    }

    /* Close button */
    .close-button {
        background: var(--bg-button);
        color: var(--text-primary);
        text-shadow: none;
        padding: 0;
        border-radius: 50%;
        margin-top: 8px;
        margin-right: 8px;
        min-width: 20px;
        min-height: 20px;
    }
    .close-button:hover { background: var(--bg-button-hover); }

    /* Notification rows */
    .notification-row { background: none; }
    .notification-row:focus,
    .notification-group:focus { background: var(--bg-primary); }
    .notification-row .notification-background { margin: 0px; }

    /* Base notification */
    .notification-row .notification-background .notification {
        border-radius: 0px;
        border: 1px solid var(--border-color);
        transition: background var(--transition-standard);
        background: var(--bg-primary);
        padding: 2px 4px;
    }

    /* Priority accent bar */
    .notification-row .notification-background .notification.low {
        border-left: 3px solid var(--priority-low);
    }
    .notification-row .notification-background .notification.normal {
        border-left: 3px solid var(--priority-normal);
    }
    .notification-row .notification-background .notification.critical {
        border-left: 3px solid var(--priority-critical);
    }

    /* Default action */
    .notification-default-action {
        padding: 4px;
        margin: 0;
        box-shadow: none;
        background: transparent;
        border: none;
        color: var(--text-primary);
        transition: background var(--transition-standard);
        border-radius: 0px;
    }
    .notification-default-action:hover { background: var(--bg-secondary); }
    .notification-default-action:not(:only-child) {
        border-bottom-left-radius: 0px;
        border-bottom-right-radius: 0px;
    }

    /* Notification content */
    .notification-content {
        background: transparent;
        border-radius: 0px;
        padding: 0;
    }
    .notification-content .image {
        -gtk-icon-size: 30px;
        border-radius: 50px;
        margin: 0px 7px 0px 0px;
    }
    .notification-content .app-icon {
        -gtk-icon-size: calc(25px / 3);
        margin: 6px;
    }
    .notification-content .text-box .summary,
    .notification-content .text-box .time,
    .notification-content .text-box .body {
        font-family: "${font}";
        font-size: 14px;
        background: transparent;
        color: var(--text-primary);
        text-shadow: none;
    }
    .notification-content .text-box .summary,
    .notification-content .text-box .time { font-weight: bold; }
    .notification-content .text-box .time { margin-right: 30px; }
    .notification-content .text-box .body { font-weight: normal; }

    /* Inline reply */
    .notification-content .inline-reply .inline-reply-entry {
        background: var(--bg-secondary);
        color: var(--text-primary);
        caret-color: var(--text-primary);
        border: 1px solid var(--border-color);
        border-radius: 0px;
    }
    .notification-content .inline-reply .inline-reply-button {
        margin-left: 4px;
        background: var(--bg-button);
        border: 1px solid var(--border-color);
        border-radius: 0px;
        color: var(--text-primary);
    }
    .notification-content .inline-reply .inline-reply-button:hover {
        background: var(--bg-primary);
    }

    /* Alternative actions */
    .notification-alt-actions {
        background: none;
        padding: 4px;
    }
    .notification-action { margin: 4px; padding: 0; font-size: 14px; }
    .notification-action > button { border-radius: 0px; font-size: 14px; padding: 1px; }

    /* Notification groups */
    .notification-group { transition: opacity 200ms ease-in-out; }
    .notification-group .notification-group-close-button .close-button { margin: 12px 20px; }
    .notification-group .notification-group-buttons,
    .notification-group .notification-group-headers { margin: 0 16px; color: var(--text-primary); }
    .notification-group .notification-group-headers { font-size: 14px; }
    .notification-group .notification-group-headers .notification-group-icon {
        color: var(--text-primary);
        -gtk-icon-size: 20px;
        font-size: 14px;
        font-weight: 700;
        margin: 5px 5px 5px 0px;
    }
    .notification-group .notification-group-headers .notification-group-header {
        font-size: 14px;
        font-weight: 700;
        color: var(--text-primary);
    }
    .notification-group .notification-group-buttons { margin: 5px; }
    .notification-group.collapsed.not-expanded { opacity: 1.0; }
    .notification-group.collapsed .notification-row .notification {
        background-color: var(--bg-primary);
    }
    .notification-group.collapsed:hover .notification-row:not(:only-child) .notification {
        background-color: var(--bg-primary);
    }

    /* Control center */
    .control-center {
        background: var(--bg-primary);
        color: var(--text-primary);
        border-radius: 0px;
        border: 2px solid var(--border-color);
        box-shadow: 0 4px 16px rgba(0, 0, 0, 0.5);
    }
    .control-center .control-center-list { background: transparent; }
    .control-center .control-center-list .notification .notification-default-action:hover,
    .control-center .control-center-list .notification .notification-action:hover {
        background-color: var(--bg-secondary);
    }

    /* Floating notifications */
    .blank-window,
    .floating-notifications { background: transparent; }
    .floating-notifications .notification { box-shadow: none; }

    /* Widgets */
    .widget-title > label {
        margin: 8px;
        font-weight: 700;
        font-size: 14px;
        color: var(--text-primary);
    }
    .widget-title > button {
        margin: 8px;
        font-size: 14px;
        background: var(--bg-secondary);
        border: 1px solid var(--border-color);
        padding: 3px 10px;
        color: var(--text-primary);
        font-weight: 700;
    }
    .widget-title > button:hover { background: var(--bg-button-hover); }

    /* Common widget padding */
    .widget-dnd,
    .widget-label,
    .widget-volume,
    .widget-slider,
    .widget-backlight {
        margin-left: 8px;
        margin-right: 8px;
        margin-top: 0px;
        margin-bottom: 0px;
    }
    .widget-dnd label,
    .widget-label > label {
        color: var(--text-primary);
        font-size: 14px;
    }
    .widget-dnd label { margin: 8px; margin-top: 16px; }
    .widget-dnd switch { margin: 8px; margin-top: 16px; }
    .widget-dnd switch slider { border-radius: 0px; }
    .widget-label { margin: 8px; }

    /* Mpris */
    .widget-mpris { margin: 5px; }
    .widget-mpris .widget-mpris-player {
        margin: 10px 10px;
        border-radius: 0px;
        box-shadow: 0px 0px 10px rgba(0, 0, 0, 0.75);
        border: 1px solid var(--border-color);
    }
    .widget-mpris .widget-mpris-player .mpris-overlay {
        padding: 16px;
        background-color: rgba(0, 0, 0, 0.55);
    }
    .widget-mpris .widget-mpris-player .mpris-overlay button:hover {
        background: var(--bg-secondary);
    }
    .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-album-art {
        border-radius: 0px;
        -gtk-icon-size: 50px;
    }
    .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-title {
        font-weight: bold;
        font-size: 14px;
    }
    .widget-mpris .widget-mpris-player .mpris-overlay .widget-mpris-subtitle { font-size: 14px; }
    .widget-mpris .widget-mpris-player .mpris-overlay > box > button {
        margin: 2px;
        color: var(--text-primary);
    }
    .widget-mpris > box > button { color: var(--text-primary); }
    .widget-mpris > box > button:disabled { color: var(--text-disabled); }

    /* Volume widget */
    .widget-volume {
        padding: 8px;
        margin-bottom: 8px;
        border-radius: 0px;
    }
    .per-app-volume {
        background-color: var(--bg-secondary);
        padding: 8px;
        margin: 8px;
        border-radius: 0px;
    }

    /* Slider */
    .widget-slider { padding: 8px; border-radius: 0px; }
    .widget-slider label { font-size: inherit; }

    /* Backlight */
    .widget-backlight {
        padding: 8px;
        border-radius: 0px;
        margin-top: -8px;
        margin-bottom: 8px;
    }
  '';
}
