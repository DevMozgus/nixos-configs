# Shared home-manager config: shell, git, theming, apps
{
  inputs,
  pkgs,
  lib,
  ...
}:
{
  imports = [
    inputs.nixvim.homeModules.nixvim
    ./1password.nix
    ./shell.nix
    ./git.nix
    ./terminal.nix
    ./vscode.nix
    ./firefox.nix
    ./librewolf.nix
    ./zen-browser.nix
    ./neovim.nix
    ./rofi.nix
    ./swaync.nix
    ./swayosd.nix
    ./storage.nix
    ./hyprland
    ./waybar
    ./opencode.nix
    ./javascript.nix
  ];

  home = {
    username = "nicola";
    homeDirectory = "/home/nicola";
    stateVersion = "25.05";

    packages = with pkgs; [
      # Browsers
      google-chrome

      # Media players
      mpv
      jellyfin-media-player
      jellyfin-tui

      # File management
      kdePackages.dolphin
      peazip
      imv
      kdePackages.okular

      # Dolphin thumbnailers (file previews)
      kdePackages.ffmpegthumbs
      kdePackages.kdegraphics-thumbnailers
      kdePackages.kimageformats
      kdePackages.qtimageformats
      kdePackages.kdesdk-thumbnailers
      taglib
      icoutils
      resvg

      # Networking / remote
      netbird
      rustdesk

      # Graphics
      inkscape

      # Communication
      signal-desktop
      telegram-desktop

      # Recording / streaming
      obs-studio

      # System monitoring
      btop
      pavucontrol

      # Office
      libreoffice
    ];
  };

  # Syncthing user-level service
  services.syncthing.enable = true;

  gtk.gtk4.theme = null;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      # Browser
      "text/html" = "zen-beta.desktop";
      "x-scheme-handler/http" = "zen-beta.desktop";
      "x-scheme-handler/https" = "zen-beta.desktop";
      "application/xhtml+xml" = "zen-beta.desktop";

      # File manager
      "inode/directory" = "org.kde.dolphin.desktop";
      "x-scheme-handler/file" = "org.kde.dolphin.desktop";

      # Text
      "text/plain" = "nvim.desktop";
      "x-scheme-handler/terminal" = "kitty.desktop";

      # Video → mpv
      "video/mp4" = "mpv.desktop";
      "video/x-matroska" = "mpv.desktop";
      "video/webm" = "mpv.desktop";
      "video/avi" = "mpv.desktop";
      "video/quicktime" = "mpv.desktop";
      "video/x-msvideo" = "mpv.desktop";
      "video/mpeg" = "mpv.desktop";
      "video/3gpp" = "mpv.desktop";
      "video/ogg" = "mpv.desktop";
      "video/x-flv" = "mpv.desktop";

      # Audio → mpv
      "audio/mpeg" = "mpv.desktop";
      "audio/mp4" = "mpv.desktop";
      "audio/ogg" = "mpv.desktop";
      "audio/flac" = "mpv.desktop";
      "audio/x-flac" = "mpv.desktop";
      "audio/wav" = "mpv.desktop";
      "audio/x-wav" = "mpv.desktop";
      "audio/aac" = "mpv.desktop";

      # Images → imv
      "image/jpeg" = "imv.desktop";
      "image/png" = "imv.desktop";
      "image/gif" = "imv.desktop";
      "image/webp" = "imv.desktop";
      "image/svg+xml" = "imv.desktop";
      "image/bmp" = "imv.desktop";
      "image/tiff" = "imv.desktop";
      "image/x-portable-pixmap" = "imv.desktop";

      # PDF → okular
      "application/pdf" = "org.kde.okular.desktop";

      # Archives → peazip
      "application/zip" = "peazip.desktop";
      "application/x-tar" = "peazip.desktop";
      "application/gzip" = "peazip.desktop";
      "application/x-bzip2" = "peazip.desktop";
      "application/x-xz" = "peazip.desktop";
      "application/x-7z-compressed" = "peazip.desktop";
      "application/x-rar" = "peazip.desktop";
    };
  };

  # Dolphin MIME fix: kbuildsycoca6 requires an applications.menu to enumerate
  # installed apps. Without a full Plasma install, this file is absent and
  # Dolphin's "Open With" menu is empty. A minimal FreeDesktop menu that
  # includes <DefaultAppDirs/> is sufficient.
  xdg.configFile."menus/applications.menu".text = ''
    <!DOCTYPE Menu PUBLIC "-//freedesktop//DTD Menu 1.0//EN"
      "http://www.freedesktop.org/standards/menu-spec/1.0/menu.dtd">
    <Menu>
      <Name>Applications</Name>
      <DefaultAppDirs/>
      <DefaultDirectoryDirs/>
      <DefaultLayout>
        <Merge type="menus"/>
        <Merge type="files"/>
      </DefaultLayout>
    </Menu>
  '';

  # Rebuild the KDE service cache after every switch so Dolphin immediately
  # picks up the new applications.menu and any newly installed .desktop files.
  home.activation.rebuildKSycoca = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    rm -f "$HOME/.cache/ksycoca6_"*
    ${lib.getExe' pkgs.kdePackages.kservice "kbuildsycoca6"} --noincremental 2>/dev/null || true
  '';

  programs.home-manager.enable = true;
}
