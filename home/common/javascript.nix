# Node.js (includes npm), Bun — with working global package installs
{ pkgs, config, ... }:
{
  home.packages = with pkgs; [
    nodejs
    bun
    deno
    playwright-driver.browsers
  ];

  # Playwright browsers path — required on NixOS (bundled binaries lack dynamic deps)
  # NOTE: the nixpkgs playwright version must match @playwright/test in package[-lock].json
  home.sessionVariables = {
    PLAYWRIGHT_BROWSERS_PATH = "${pkgs.playwright-driver.browsers}";
    PLAYWRIGHT_SKIP_VALIDATE_HOST_REQUIREMENTS = "true";
  };

  # Redirect npm global prefix into home so `npm install -g` works
  # (Nix store is read-only, so the default prefix inside /nix/store fails)
  home.file.".npmrc".text = ''
    prefix=${config.home.homeDirectory}/.npm-global
  '';

  # Add both global bin dirs to PATH
  home.sessionPath = [
    "${config.home.homeDirectory}/.npm-global/bin"
    "${config.home.homeDirectory}/.bun/bin"
  ];
}
