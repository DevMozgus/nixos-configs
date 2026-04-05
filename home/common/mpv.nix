# mpv with ModernZ OSC — styled to Material Deep Ocean
{
  pkgs,
  config,
  lib,
  ...
}:
let
  c = config.lib.stylix.colors.withHashtag;
in
{
  programs.mpv = {
    enable = true;

    # ffmpeg-full adds codec support for H.265/HEVC, AV1, VP9, Opus, etc.
    # Scripts are bundled into the package override because `package` and
    # `scripts` are mutually exclusive in the home-manager mpv module.
    package = pkgs.mpv.override {
      mpv-unwrapped = pkgs.mpv-unwrapped.override {
        ffmpeg = pkgs.ffmpeg-full;
      };
      scripts = with pkgs.mpvScripts; [
        modernz
        sponsorblock
      ];
    };

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

      # Colors — Material Deep Ocean palette (lib.mkForce overrides Stylix mpv module)
      osc_color = lib.mkForce c.base00; # #0F111A  dark background
      seekbarfg_color = lib.mkForce c.base0D; # #82AAFF  blue accent
      seekbarbg_color = lib.mkForce c.base03; # #464B5D  muted blue-grey
      hover_effect_color = lib.mkForce c.base0D; # #82AAFF
      nibble_color = lib.mkForce c.base0D; # #82AAFF
      title_color = lib.mkForce c.base06; # #EEFFFF  light foreground
      time_color = lib.mkForce c.base05; # #8F93A2  foreground
      chapter_title_color = lib.mkForce c.base05; # #8F93A2
      side_buttons_color = lib.mkForce c.base06; # #EEFFFF
      middle_buttons_color = lib.mkForce c.base06; # #EEFFFF
      playpause_color = lib.mkForce c.base06; # #EEFFFF
    };
  };
}
