# mpv with ModernZ OSC — styled to Material Deep Ocean
{ pkgs, config, ... }:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.mpv = {
    enable = true;

    # ffmpeg-full adds codec support for H.265/HEVC, AV1, VP9, Opus, etc.
    package = pkgs.mpv.override {
      mpv-unwrapped = pkgs.mpv-unwrapped.override {
        ffmpeg = pkgs.ffmpeg-full;
      };
    };

    scripts = with pkgs.mpvScripts; [ modernz sponsorblock ];

    config = {
      # Required: disable the stock OSC so ModernZ takes over
      osc = "no";

      # Hardware decoding — auto-safe uses VA-API/VDPAU without crashing on unsupported formats
      hwdec = "auto-safe";

      # High-quality upscaling/downscaling
      profile = "high-quality";
    };

    scriptOpts.modernz = {
      # Layout
      layout = "modern";
      icon_theme = "material";
      icon_style = "filled";
      seekbar_height = "medium";

      # Colors — Material Deep Ocean palette
      osc_color            = c.base00; # #0F111A  dark background
      seekbarfg_color      = c.base0D; # #82AAFF  blue accent
      seekbarbg_color      = c.base03; # #464B5D  muted blue-grey
      hover_effect_color   = c.base0D; # #82AAFF
      nibble_color         = c.base0D; # #82AAFF
      title_color          = c.base06; # #EEFFFF  light foreground
      time_color           = c.base05; # #8F93A2  foreground
      chapter_title_color  = c.base05; # #8F93A2
      side_buttons_color   = c.base06; # #EEFFFF
      middle_buttons_color = c.base06; # #EEFFFF
      playpause_color      = c.base06; # #EEFFFF
    };
  };
}
