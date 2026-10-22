# OBS plugin: Image Reaction — swaps two images based on audio input level
# (audio-reactive PNGtuber without external apps)
{
  stdenv,
  lib,
  fetchFromGitHub,
  cmake,
  obs-studio,
}:

stdenv.mkDerivation {
  pname = "obs-image-reaction";
  version = "1.3.0";

  src = fetchFromGitHub {
    owner = "scaledteam";
    repo = "obs-image-reaction";
    rev = "1.3"; # tag for 1.3.0
    hash = "sha256-mC1B8tveHx35pfbAcOlosB8YKaBVg87MjXbr79sf7+k=";
  };

  # Plain C plugin: libobs only (Qt/frontend API are OFF by default upstream)
  nativeBuildInputs = [ cmake ];

  buildInputs = [ obs-studio ];

  # The obs-plugintemplate also installs a legacy layout next to the modern
  # lib/obs-plugins + share/obs/obs-plugins one; prune the duplicate.
  postInstall = ''
    rm -rf $out/obs-plugins $out/data
  '';

  meta = with lib; {
    description = "OBS Studio plugin that switches between two images based on audio volume";
    homepage = "https://github.com/scaledteam/obs-image-reaction";
    license = licenses.gpl2Plus;
    platforms = platforms.linux;
  };
}
