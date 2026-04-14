# Firefox extension: Open in MPV (packaged from AMO)
{
  stdenv,
  fetchurl,
  lib,
}:

let
  addonId = "{d66c8515-1e0d-408f-82ee-2682f2362726}";
in
stdenv.mkDerivation rec {
  pname = "firefox-addon-open-in-mpv";
  version = "2.4.3";

  src = fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4415443/iina_open_in_mpv-${version}.xpi";
    sha256 = "0f8dj1b16n80g42k318qb630ybg9a9dhv44g1ln46snfd2apg2c2";
  };

  preferLocalBuild = true;
  allowSubstitutes = true;

  phases = [ "installPhase" ];

  installPhase = ''
    dst="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$dst"
    install -v -m644 "$src" "$dst/${addonId}.xpi"
  '';

  meta = with lib; {
    description = "Open videos in mpv from your browser";
    homepage = "https://github.com/Baldomo/open-in-mpv";
    license = licenses.gpl3Only;
    platforms = platforms.all;
  };
}
