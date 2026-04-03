# Rofi launcher — custom Material Deep Ocean theme (style-1.rasi inspired)
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors;
  font = config.stylix.fonts.monospace.name;
in
{
  # Disable Stylix auto-theme so our custom rasi takes full control
  stylix.targets.rofi.enable = false;

  programs.rofi = {
    enable = true;
    package = pkgs.rofi;
    terminal = "${pkgs.kitty}/bin/kitty";
    theme = "${config.xdg.configHome}/rofi/theme.rasi";
    extraConfig = {
      modi = "drun";
      show-icons = true;
      display-drun = "";
      drun-display-format = "{name}";
      window-format = "{t}";
    };
  };

  xdg.configFile."rofi/theme.rasi".text = ''
    /**
     * Material Deep Ocean — Rofi Theme
     * Layout inspired by adi1090x/style-1.rasi
     **/

    * {
        bg:      #${c.base00}FF;
        bg-alt:  #${c.base01}FF;
        bg-sel:  #${c.base02}FF;
        fg:      #${c.base05}FF;
        fg-em:   #${c.base06}EE;
        accent:  #${c.base0D}FF;
        comment: #${c.base03}CC;
        font:    "${font} 11";
    }

    window {
        transparency:     "real";
        location:         center;
        anchor:           center;
        fullscreen:       false;
        width:            460px;
        border:           0px solid;
        border-radius:    14px;
        border-color:     @accent;
        background-color: @bg;
        cursor:           "default";
    }

    mainbox {
        enabled:          true;
        spacing:          0px;
        background-color: transparent;
        children:         [ "inputbar", "listview" ];
    }

    inputbar {
        enabled:          true;
        spacing:          10px;
        padding:          14px 16px;
        border-radius:    14px 14px 0px 0px;
        background-color: @bg-alt;
        text-color:       @accent;
        children:         [ "prompt", "entry" ];
    }

    prompt {
        enabled:          true;
        background-color: inherit;
        text-color:       inherit;
    }

    entry {
        enabled:          true;
        background-color: inherit;
        text-color:       @fg-em;
        cursor:           text;
        placeholder:      "Search...";
        placeholder-color: @comment;
    }

    listview {
        enabled:          true;
        columns:          1;
        lines:            8;
        cycle:            true;
        dynamic:          true;
        scrollbar:        false;
        layout:           vertical;
        spacing:          2px;
        padding:          8px;
        border-radius:    0px 0px 14px 14px;
        background-color: @bg;
        text-color:       @fg;
        cursor:           "default";
    }

    element {
        enabled:          true;
        spacing:          12px;
        padding:          8px 12px;
        border:           0px solid;
        border-radius:    8px;
        background-color: transparent;
        text-color:       @fg;
        cursor:           pointer;
    }

    element normal.normal {
        background-color: transparent;
        text-color:       @fg;
    }

    element selected.normal {
        background-color: @bg-sel;
        text-color:       @fg-em;
    }

    element-icon {
        background-color: transparent;
        text-color:       inherit;
        size:             28px;
        cursor:           inherit;
    }

    element-text {
        background-color: transparent;
        text-color:       inherit;
        highlight:        inherit;
        cursor:           inherit;
        vertical-align:   0.5;
        horizontal-align: 0.0;
    }

    error-message {
        padding:          16px;
        border:           2px solid;
        border-radius:    14px;
        border-color:     @accent;
        background-color: @bg;
        text-color:       @fg;
    }
  '';

  # Power menu theme — horizontal icon picker, inherits palette from above
  xdg.configFile."rofi/powermenu-theme.rasi".text = ''
    /**
     * Material Deep Ocean — Rofi Power Menu Theme
     * Horizontal icon picker: 5 columns × 1 row
     **/

    * {
        bg:     #${c.base00}FF;
        fg:     #${c.base05}FF;
        sel:    #${c.base02}FF;
        border: #${c.base04}FF;
        red:    #${c.base08}FF;
        font:   "${font} Bold 26";
    }

    configuration {
        show-icons: false;
    }

    window {
        width:            500px;
        location:         center;
        anchor:           center;
        margin:           0px;
        padding:          0px;
        border:           2px solid;
        border-radius:    0px;
        border-color:     @border;
        background-color: @bg;
        cursor:           "default";
    }

    mainbox {
        enabled:          true;
        background-color: inherit;
        children:         [ "listview" ];
    }

    listview {
        enabled:          true;
        lines:            1;
        columns:          5;
        cycle:            true;
        dynamic:          true;
        scrollbar:        false;
        layout:           vertical;
        reverse:          false;
        fixed-height:     true;
        fixed-columns:    true;
        spacing:          0px;
        background-color: transparent;
        text-color:       @fg;
    }

    element {
        enabled:          true;
        spacing:          0px;
        padding:          24px 0px;
        border:           0px 0px 0px 0px;
        border-radius:    0px;
        background-color: inherit;
        text-color:       @fg;
        cursor:           pointer;
    }

    element-text {
        vertical-align:   0.5;
        horizontal-align: 0.5;
        font:             inherit;
        text-color:       inherit;
        background-color: transparent;
        cursor:           inherit;
    }

    element selected.normal {
        background-color: @sel;
        text-color:       @red;
    }
  '';
}
