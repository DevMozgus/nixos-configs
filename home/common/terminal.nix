# Kitty terminal: font, padding, scrollback — colors handled by Stylix
{ ... }:
{
  programs.kitty = {
    enable = true;
    font.size = 13;
    settings = {
      window_padding_width = 12;
      scrollback_lines = 10000;
      copy_on_select = "yes";
      enable_audio_bell = "no";
    };
  };
}
