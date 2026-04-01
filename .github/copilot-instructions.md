# GitHub Copilot — NixOS Configs Instructions

This is a fully declarative NixOS flake managing three hosts (desktop, laptop, vm) with
Hyprland + Waybar, Stylix theming, NixVim, and home-manager as a NixOS sub-module.
All code is in Nix. Never suggest imperative shell workarounds for things that belong in Nix.

---

## Repository layout

```
flake.nix                         # Inputs, mkHost helper, nixosConfigurations
themes/material-deep-ocean.yaml   # Base16 colour scheme — single source of truth
assets/wallpaper.png              # Wallpaper consumed by Stylix

hosts/
  common/
    global/                       # NixOS modules applied to every host
      default.nix                 #   Imports nix/locale/users/boot + ALL Stylix config
      boot.nix                    #   systemd-boot, Plymouth (material-deep-ocean theme)
      nix.nix                     #   Flake settings, GC, substituters
      locale.nix                  #   Europe/Vienna, en_US + de_AT overrides
      users.nix                   #   nicola user, zsh shell, hashedPasswordFile
    optional/                     # Opt-in NixOS modules; imported per-host
      hyprland.nix                #   Hyprland + UWSM, portals, polkit, PAM
      sddm.nix                    #   SDDM wayland, omarchy theme, sddmOmarchy pkg
      audio.nix                   #   PipeWire + WirePlumber
      bluetooth.nix               #   BlueZ + blueman
      docker.nix                  #   Docker daemon + autoPrune
  desktop/
    default.nix                   # Imports global + all optionals; hostName="desktop"
    disko-config.nix              # LUKS2 + btrfs declarative disk layout
    hardware-configuration.nix
  laptop/
    default.nix                   # Same optionals + TLP, logind, brightnessctl
    disko-config.nix
    hardware-configuration.nix
  vm/
    default.nix                   # Inherits ../desktop; overrides with lib.mkForce

home/
  desktop.nix                     # HM entry: imports ./common (isLaptop=false)
  laptop.nix                      # HM entry: imports ./common (isLaptop=true)
  common/
    default.nix                   # Aggregates all HM modules; sets home.{username,stateVersion}
    shell.nix                     # Zsh + starship + direnv + zoxide; UWSM auto-start
    git.nix                       # Git identity + delta pager
    terminal.nix                  # Kitty (colours from Stylix; font.size = lib.mkForce 13)
    vscode.nix                    # VSCodium + nix-vscode-extensions + Stylix colour overrides
    firefox.nix                   # Firefox + NUR extensions + Stylix userChrome
    neovim.nix                    # NixVim: LSP (nil_ls/pyright/ts_ls), Telescope, Treesitter
    rofi.nix                      # rofi-wayland (Stylix auto-themes)
    hyprland/
      default.nix                 # Keybinds, animations, exec-once; conditionally imports laptop.nix
      laptop.nix                  # Touchpad, gestures, lid-switch bindl
    waybar/
      default.nix                 # Bar layout; lib.optionals isLaptop for battery/backlight/network

pkgs/
  default.nix                     # { pkgs }: { materialDeepOceanPlymouth = pkgs.callPackage … }
  plymouth-material-deep-ocean/
    default.nix                   # stdenv.mkDerivation; writeText for .plymouth + .script; imagemagick assets
  sddm-omarchy/
    default.nix                   # stdenv.mkDerivation; writeText for Main.qml; copies nixos-icons SVG

overlays/
  default.nix                     # List of 3 overlays: nix-vscode-extensions, NUR, custom pkgs
```

---

## flake.nix — mkHost + VM

```nix
mkHost = hostname: extraModules: nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = { inherit inputs self; };
  modules = [
    disko.nixosModules.disko
    stylix.nixosModules.stylix
    home-manager.nixosModules.home-manager
    ./hosts/${hostname}
    ./hosts/${hostname}/disko-config.nix
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        backupFileExtension = "hm-backup";
        extraSpecialArgs = { inherit inputs; isLaptop = (hostname == "laptop"); };
        users.nicola = import ./home/${hostname}.nix;
      };
    }
    { nixpkgs.overlays = import ./overlays { inherit inputs; }; }
  ] ++ extraModules;
};
```

- `specialArgs` carries `inputs` and `self` into every NixOS module.
- `extraSpecialArgs` carries `inputs` and `isLaptop` into every home-manager module.
- The VM does **not** use `mkHost`; it manually lists modules and uses `lib.mkForce` to override values inherited from `../desktop`.
- `extraModules` is always `[]` today; it exists for future per-host additions.

---

## Stylix — theming architecture

**Single source of truth:** `hosts/common/global/default.nix` configures Stylix completely.

```nix
stylix = {
  enable = true;
  autoEnable = true;          # Applies to every supported target automatically
  polarity = "dark";
  base16Scheme = ./../../../themes/material-deep-ocean.yaml;
  image = ./../../../assets/wallpaper.png;
  imageScalingMode = "fill";

  fonts = {
    monospace  = { package = pkgs.nerd-fonts.jetbrains-mono; name = "JetBrainsMono Nerd Font"; };
    sansSerif  = { package = pkgs.inter;                      name = "Inter"; };
    emoji      = { package = pkgs.noto-fonts-color-emoji;     name = "Noto Color Emoji"; };
  };

  cursor = { package = pkgs.bibata-cursors; name = "Bibata-Modern-Classic"; size = 24; };
  opacity.terminal = 0.95;
};
```

### Material Deep Ocean palette (base16)

| Slot   | Hex       | Role           |
| ------ | --------- | -------------- |
| base00 | `#0F111A` | Background     |
| base01 | `#181A29` | Alt background |
| base02 | `#1F2233` | Selection      |
| base03 | `#464B5D` | Comments       |
| base04 | `#676E95` | Dark fg        |
| base05 | `#8F93A2` | Foreground     |
| base06 | `#EEFFFF` | Light fg       |
| base07 | `#FFFFFF` | White          |
| base08 | `#FF5370` | Red / Error    |
| base09 | `#F78C6C` | Orange         |
| base0A | `#FFCB6B` | Yellow         |
| base0B | `#C3E88D` | Green          |
| base0C | `#89DDFF` | Cyan           |
| base0D | `#82AAFF` | Blue / Accent  |
| base0E | `#C792EA` | Purple         |
| base0F | `#F07178` | Coral          |

### Accessing colours in Nix modules

```nix
# In a home-manager module that receives `config`:
let c = config.lib.stylix.colors.withHashtag; in
{ color = c.base0D; }   # → "#82AAFF"

# Without hashtag:
config.lib.stylix.colors.base0D   # → "82AAFF"
```

### Targets that need manual handling

| Target   | Why                                                                  | How                                                                             |
| -------- | -------------------------------------------------------------------- | ------------------------------------------------------------------------------- |
| Plymouth | Custom script-theme, not a Stylix target                             | `boot.plymouth.theme = lib.mkForce "material-deep-ocean"`                       |
| SDDM     | Custom QML theme; Stylix has no `sddm` target                        | `services.displayManager.sddm.theme = "omarchy"` overrides Stylix automatically |
| GTK4     | Stylix GTK4 override causes issues                                   | `gtk.gtk4.theme = null` in `home/common/default.nix`                            |
| Kitty    | Stylix handles colours; override font size only                      | `font.size = lib.mkForce 13`                                                    |
| Waybar   | Stylix CSS generated first; custom rules appended with `lib.mkAfter` | `style = lib.mkAfter ''…''`                                                     |
| Firefox  | Stylix targets the profile; userChrome uses colour vars              | `config.lib.stylix.colors.withHashtag`                                          |
| VSCode   | `workbench.colorCustomizations."[Stylix]"` uses Stylix palette       | `config.lib.stylix.colors.withHashtag`                                          |

---

## Custom packages and overlays

### Overlay definition (`overlays/default.nix`)

```nix
{ inputs }:
[
  inputs.nix-vscode-extensions.overlays.default  # → pkgs.vscode-marketplace.*
  inputs.nur.overlays.default                    # → pkgs.nur.repos.rycee.firefox-addons.*
  (final: prev: {
    materialDeepOceanPlymouth = prev.callPackage ../pkgs/plymouth-material-deep-ocean {
      nixosIcons = prev.nixos-icons;
    };
    sddmOmarchy = prev.callPackage ../pkgs/sddm-omarchy {
      nixosIcons = prev.nixos-icons;
    };
  })
]
```

Overlays are injected via `{ nixpkgs.overlays = import ./overlays { inherit inputs; }; }` in `mkHost`.

### Adding a new custom package

1. Create `pkgs/<name>/default.nix` as a standard `stdenv.mkDerivation` or `writeShellApplication`.
2. Add to the custom overlay in `overlays/default.nix`:
   ```nix
   <camelCaseName> = prev.callPackage ../pkgs/<name> { };
   ```
3. Reference as `pkgs.<camelCaseName>` anywhere in host or home modules.
4. Do **not** edit `pkgs/default.nix` for new packages — it is legacy; overlays are the correct path.

### Package conventions

- Use `writeText` for embedded file content (QML, scripts, config files) rather than separate source files.
- Generate binary assets inside the derivation via `imagemagick` / `librsvg` — never `fetchurl` raw PNGs.
- Pass external packages as explicit derivation arguments (e.g. `nixosIcons`) rather than `pkgs.nixos-icons` inside the derivation body.
- Theme packages use `phases = [ "installPhase" ]` when there is no compilation step.

---

## Adding a new optional NixOS module

Create `hosts/common/optional/<name>.nix` following this convention:

```nix
# Short description of what this module enables
{ pkgs, ... }:
{
  # NixOS options…
}
```

Then import it explicitly in each host `default.nix` that needs it. Optional modules are **never**
auto-imported; every import is explicit.

---

## Adding a new home-manager module

1. Create `home/common/<name>.nix`.
2. Add `./name` to the `imports` list in `home/common/default.nix`.
3. The module receives `{ pkgs, config, lib, inputs, isLaptop, ... }`.

---

## isLaptop flag

Passed as `extraSpecialArgs` from the flake. Use it for conditional configuration:

```nix
# home-manager module
{ lib, isLaptop, ... }:
{
  # Waybar pattern
  modules-right = (lib.optionals isLaptop [ "battery" "backlight" "network" ]) ++ [ "cpu" ];

  # Hyprland pattern
  imports = [] ++ (if isLaptop then [ ./laptop.nix ] else []);

  # Inline condition
  monitor = if isLaptop then [ ", preferred, auto, 1" ] else [ "DP-1, 2560x1440@144, 0x0, 1" ];
}
```

---

## lib.mkForce usage

Use `lib.mkForce` only in the VM host to override values inherited from `../desktop`:

```nix
disko.devices = lib.mkForce {};
fileSystems = lib.mkForce { "/" = { device = "/dev/disk/by-label/nixos"; fsType = "ext4"; }; };
boot.plymouth.enable = lib.mkForce false;
networking.hostName = lib.mkForce "vm";
```

Do not use `lib.mkForce` inside `hosts/common/global/boot.nix` except for the Plymouth theme
name (which must override anything a host might set):

```nix
boot.plymouth.theme = lib.mkForce "material-deep-ocean";
```

---

## Hyprland conventions

- NixOS side (`hosts/common/optional/hyprland.nix`): enables the compositor, UWSM, portals, polkit, PAM.
- Home side (`home/common/hyprland/default.nix`): configures keybindings, animations, `exec-once`, monitor layout.
- Always set `package = null` and `portalPackage = null` in the home module (packages come from the NixOS module).
- Always set `systemd.enable = false` (UWSM handles the systemd session).
- Hyprland is launched via UWSM from `~/.zprofile` (the `profileExtra` in `shell.nix`).

---

## Plymouth / SDDM theming

- Plymouth theme name: `material-deep-ocean` — do not rename (boot.nix references it).
- Plymouth package: `pkgs.materialDeepOceanPlymouth` (from overlay).
- SDDM theme name: `omarchy` — the QML `metadata.desktop` names it.
- SDDM package: `pkgs.sddmOmarchy` (from overlay); added to `environment.systemPackages`.
- Both themes use colours hard-coded from the Material Deep Ocean palette (not Stylix-generated at
  build time, since these run before home-manager). Keep hex values in sync with `themes/material-deep-ocean.yaml`.

---

## Substituters / caches

Three caches are configured in `hosts/common/global/nix.nix`:

- `cache.nixos.org` — main NixOS cache
- `hyprland.cachix.org` — pre-built Hyprland
- `nix-community.cachix.org` — NixVim, home-manager, stylix, nix-vscode-extensions

When adding a new flake input that has a public cache, add its URL and public key here.

---

## Key constraints and do-nots

- **Never** add `system.stateVersion` other than `"25.05"` without explicit instruction.
- **Never** use `fetchurl` or `builtins.fetchTarball` for theme assets — generate them in the derivation.
- **Never** add a NixOS module to `hosts/common/global/` unless it truly belongs on every host (the four existing files — nix, locale, users, boot — cover everything global).
- **Never** import an optional module in `hosts/common/global/default.nix`; optional modules belong only in per-host `default.nix` files.
- **Never** configure Stylix colours/fonts/cursor outside of `hosts/common/global/default.nix`.
- **Always** run `git add -A` before `nixos-rebuild switch --flake .#<hostname>`.
- **Always** use `lib.mkForce` when overriding NixOS options in the VM host.
- **Always** place new home-manager modules under `home/common/` and register them in `home/common/default.nix`.

---

DO NOT RUN ANYTHING TO VERIFY IF CHANGES WORK WITHOUT EXPLICIT INSTRUCTION.

Assume this sytsem isn't running on a machine configured with nix.
