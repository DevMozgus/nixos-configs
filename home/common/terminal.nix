# Kitty terminal: font, padding, scrollback — colors handled by Stylix
{ lib, ... }:
{
  programs.kitty = {
    enable = true;
    font.size = lib.mkForce 13;
    settings = {
      window_padding_width = 12;
      scrollback_lines = 10000;
      copy_on_select = "yes";
      enable_audio_bell = "no";
    };
  };
}
