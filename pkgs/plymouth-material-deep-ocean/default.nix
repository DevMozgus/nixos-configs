# Custom Plymouth script-theme: Material Deep Ocean
{ stdenv, lib, writeText, imagemagick }:

let
  plymouthConfig = writeText "material-deep-ocean.plymouth" ''
    [Plymouth Theme]
    Name=Material Deep Ocean
    Description=Material Deep Ocean boot splash with wallpaper and progress bar
    ModuleName=script

    [script]
    ImageDir=/share/plymouth/themes/material-deep-ocean
    ScriptFile=/share/plymouth/themes/material-deep-ocean/material-deep-ocean.script
  '';

  plymouthScript = writeText "material-deep-ocean.script" ''
    # Material Deep Ocean Plymouth Script Theme

    # Load and scale wallpaper to fill screen
    wallpaper = Image("wallpaper.png");
    screen_width = Window.GetWidth();
    screen_height = Window.GetHeight();

    wallpaper_scaled = wallpaper.Scale(screen_width, screen_height);
    wallpaper_sprite = Sprite(wallpaper_scaled);
    wallpaper_sprite.SetPosition(0, 0, -100);

    # Load the progress bar image (1px colored, scaled per progress)
    progress_image = Image("progress-bar.png");
    progress_sprite = Sprite();

    bar_height = 4;
    bar_y = screen_height - 40;

    # Boot progress callback
    fun boot_progress_cb(duration, progress) {
      bar_width = Math.Int(screen_width * progress);
      if (bar_width > 0) {
        scaled = progress_image.Scale(bar_width, bar_height);
        progress_sprite.SetImage(scaled);
        progress_sprite.SetPosition(0, bar_y, 10);
      }
    }

    Plymouth.SetBootProgressFunction(boot_progress_cb);
  '';
in
stdenv.mkDerivation {
  pname = "plymouth-material-deep-ocean";
  version = "1.0.0";

  src = ../../assets;

  nativeBuildInputs = [ imagemagick ];

  dontBuild = false;

  buildPhase = ''
    # Generate a 1x1 pixel #82AAFF (base0D blue) image for the progress bar
    magick -size 1x1 xc:'#82AAFF' progress-bar.png
  '';

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/material-deep-ocean
    cp ${plymouthConfig} $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.plymouth
    cp ${plymouthScript} $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.script
    cp $src/wallpaper.png $out/share/plymouth/themes/material-deep-ocean/wallpaper.png
    cp progress-bar.png $out/share/plymouth/themes/material-deep-ocean/progress-bar.png

    # Fix the config file paths to point to the installed location
    substituteInPlace $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.plymouth \
      --replace-warn "/share/plymouth" "$out/share/plymouth"
  '';

  meta = with lib; {
    description = "Material Deep Ocean Plymouth boot splash theme";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
