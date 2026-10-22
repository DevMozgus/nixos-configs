# OBS Studio with multi-RTMP plugin for streaming to multiple platforms,
# plus Image Reaction for audio-reactive PNGtuber avatars
{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = with pkgs.obs-studio-plugins; [
      obs-multi-rtmp
      # Audio-reactive PNGtuber plugin (custom package from pkgs/obs-image-reaction):
      # add an "Image Reaction" source, pick two images + your mic, set threshold
      pkgs.obsImageReaction
      # Optional hardware encoding (AMD/Intel):
      # obs-vaapi
      # Desktop/mic audio is captured natively via PipeWire (OBS >= 30.2)
    ];
  };
}
