# Custom Plymouth script-theme: Material Deep Ocean (omarchy-style)
# Centered logo on flat dark background with spinning circle animation
# and full password dialog (lock, entry field, bullet dots).
{ stdenv, lib, writeText, imagemagick, logo }:

let
  plymouthConfig = writeText "material-deep-ocean.plymouth" ''
    [Plymouth Theme]
    Name=Material Deep Ocean
    Description=Material Deep Ocean boot splash.
    ModuleName=script

    [script]
    ImageDir=/share/plymouth/themes/material-deep-ocean
    ScriptFile=/share/plymouth/themes/material-deep-ocean/material-deep-ocean.script
    ConsoleLogBackgroundColor=0x0F111A
    MonospaceFont=JetBrainsMono Nerd Font 11
    Font=JetBrainsMono Nerd Font 11
  '';

  plymouthScript = writeText "material-deep-ocean.script" ''
    # Material Deep Ocean Plymouth Theme Script

    Window.SetBackgroundTopColor(0.059, 0.067, 0.102);
    Window.SetBackgroundBottomColor(0.059, 0.067, 0.102);

    # Spinner state
    global.spinner_angle = 0.0;
    global.spinner_visible = 0;
    global.password_shown = 0;

    # Track screen dimensions so we can detect resolution changes
    global.screen_width = 0;
    global.screen_height = 0;

    #--- Load images and create sprites ---

    logo.image = Image("logo.png");
    logo.sprite = Sprite(logo.image);
    logo.sprite.SetOpacity(1);

    entry.image = Image("entry.png");
    entry.sprite = Sprite(entry.image);
    entry.sprite.SetOpacity(0);

    lock.image = Image("lock.png");
    lock.height_val = entry.image.GetHeight() * 0.8;
    lock.width_val = 84 * (lock.height_val / 96);
    scaled_lock = lock.image.Scale(lock.width_val, lock.height_val);
    lock.sprite = Sprite(scaled_lock);
    lock.sprite.SetOpacity(0);

    bullet.image = Image("bullet.png");
    bullet.sprites = [];

    spinner.image = Image("spinner.png");
    spinner.sprite = Sprite();
    spinner.sprite.SetOpacity(0);

    #--- Repositioning (called at init and whenever the screen resolution changes) ---

    fun reposition_sprites ()
      {
        sw = Window.GetWidth();
        sh = Window.GetHeight();

        logo.sprite.SetX(sw / 2 - logo.image.GetWidth() / 2);
        logo.sprite.SetY(sh / 2 - logo.image.GetHeight() / 2);

        spinner_y = logo.sprite.GetY() + logo.image.GetHeight() + 40;
        spinner.sprite.SetPosition(sw / 2 - spinner.image.GetWidth() / 2, spinner_y, 0);

        entry.y = logo.sprite.GetY() + logo.image.GetHeight() + 40;
        group_width = lock.width_val + 15 + entry.image.GetWidth();
        lock.x = sw / 2 - group_width / 2;
        entry.x = lock.x + lock.width_val + 15;
        lock.y = entry.y + entry.image.GetHeight() / 2 - lock.height_val / 2;

        entry.sprite.SetPosition(entry.x, entry.y, 10001);
        lock.sprite.SetPosition(lock.x, lock.y, 10001);

        for (index = 0; bullet.sprites[index]; index++)
          {
            bx = entry.x + 20 + index * 12;
            by = entry.y + entry.image.GetHeight() / 2 - 3.5;
            bullet.sprites[index].SetPosition(bx, by, 10002);
          }
      }

    reposition_sprites();

    #--- Spinner helpers ---

    fun show_spinner ()
      {
        global.spinner_visible = 1;
        spinner.sprite.SetOpacity(1);
      }

    fun hide_spinner ()
      {
        global.spinner_visible = 0;
        spinner.sprite.SetOpacity(0);
      }

    fun show_password_dialog ()
      {
        lock.sprite.SetOpacity(1);
        entry.sprite.SetOpacity(1);
      }

    fun hide_password_dialog ()
      {
        lock.sprite.SetOpacity(0);
        entry.sprite.SetOpacity(0);
        for (index = 0; bullet.sprites[index]; index++)
          bullet.sprites[index].SetOpacity(0);
      }

    #--- Refresh ---

    fun refresh_callback ()
      {
        # Reposition everything if the display resolution changed
        if (global.screen_width != Window.GetWidth() || global.screen_height != Window.GetHeight())
          {
            global.screen_width = Window.GetWidth();
            global.screen_height = Window.GetHeight();
            reposition_sprites();
          }

        if (global.spinner_visible == 1)
          {
            global.spinner_angle = global.spinner_angle + 0.2;
            if (global.spinner_angle >= 6.2832)
              global.spinner_angle = global.spinner_angle - 6.2832;
            rotated = spinner.image.Rotate(global.spinner_angle);
            spinner.sprite.SetImage(rotated);
          }
      }

    Plymouth.SetRefreshFunction (refresh_callback);

    #--- Dialogue ---

    fun display_normal_callback ()
      {
        hide_password_dialog();
        mode = Plymouth.GetMode();
        if (mode == "boot" || mode == "resume")
          show_spinner();
      }

    fun display_password_callback (prompt, bullets)
      {
        global.password_shown = 1;
        hide_spinner();
        show_password_dialog();

        for (index = 0; bullet.sprites[index]; index++)
          bullet.sprites[index].SetOpacity(0);

        max_bullets = 21;
        bullets_to_show = bullets;
        if (bullets_to_show > max_bullets)
          bullets_to_show = max_bullets;

        for (index = 0; index < bullets_to_show; index++)
          {
            if (!bullet.sprites[index])
              {
                scaled_bullet = bullet.image.Scale(7, 7);
                bullet.sprites[index] = Sprite(scaled_bullet);
                bullet.sprites[index].SetPosition(
                  entry.x + 20 + index * 12,
                  entry.y + entry.image.GetHeight() / 2 - 3.5,
                  10002);
              }
            bullet.sprites[index].SetOpacity(1);
          }
      }

    Plymouth.SetDisplayNormalFunction (display_normal_callback);
    Plymouth.SetDisplayPasswordFunction (display_password_callback);

    #--- Quit ---

    fun quit_callback ()
      {
        logo.sprite.SetOpacity(1);
      }

    Plymouth.SetQuitFunction (quit_callback);

    #--- Message ---

    message_sprite = Sprite();
    message_sprite.SetPosition(10, 10, 10000);

    fun display_message_callback (text)
      {
        my_image = Image.Text(text, 1, 1, 1);
        message_sprite.SetImage(my_image);
      }

    fun hide_message_callback (text)
      {
        message_sprite.SetOpacity(0);
      }

    Plymouth.SetDisplayMessageFunction (display_message_callback);
    Plymouth.SetHideMessageFunction (hide_message_callback);
  '';
in
stdenv.mkDerivation {
  pname = "plymouth-material-deep-ocean";
  version = "2.0.0";

  phases = [ "buildPhase" "installPhase" ];

  nativeBuildInputs = [ imagemagick ];

  buildPhase = ''
    # Spinner: 60×60px arc (270-degree, #82AAFF, 5px stroke)
    magick -size 60x60 xc:transparent \
      -fill none -stroke '#82AAFF' -strokewidth 5 \
      -draw "arc 5,5 55,55 0,270" \
      spinner.png

    # Entry field: 280×36px dark bg (#0F111A) with 1px #EEFFFF border
    magick -size 280x36 xc:'#0F111A' \
      -fill none -stroke '#EEFFFF' -strokewidth 1 \
      -draw "rectangle 0,0 279,35" \
      entry.png

    # Lock icon: padlock body (roundrectangle) + shackle (arc 180→360 = top arc)
    magick -size 84x96 xc:transparent \
      -fill white -stroke none -draw "roundrectangle 8,44 76,90 6,6" \
      -fill none -stroke white -strokewidth 10 \
      -draw "arc 18,6 66,82 180,360" \
      lock.png

    # Bullet: 8×8px white filled circle
    magick -size 8x8 xc:transparent \
      -fill white -draw "circle 4,4 4,1" \
      bullet.png
  '';

  installPhase = ''
    mkdir -p $out/share/plymouth/themes/material-deep-ocean
    cp ${plymouthConfig} $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.plymouth
    cp ${plymouthScript} $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.script
    cp ${logo} $out/share/plymouth/themes/material-deep-ocean/logo.png
    cp spinner.png entry.png lock.png bullet.png \
      $out/share/plymouth/themes/material-deep-ocean/

    substituteInPlace $out/share/plymouth/themes/material-deep-ocean/material-deep-ocean.plymouth \
      --replace-warn "/share/plymouth" "$out/share/plymouth"
  '';

  meta = with lib; {
    description = "Material Deep Ocean Plymouth boot splash theme (spinner variant)";
    license = licenses.mit;
    platforms = platforms.linux;
  };
}
