# nixos-configs

Fully declarative NixOS dotfiles for desktop and laptop systems.

## Stack

- **NixOS** with Flakes — reproducible, locked multi-host configurations
- **Hyprland** + Waybar — tiling Wayland compositor with status bar
- **Stylix** (base16) — Material Deep Ocean palette propagated to 70+ apps
- **NixVim** — declarative Neovim with LSP, Telescope, Treesitter
- **disko** + LUKS2 + btrfs — encrypted, declarative disk layout
- **home-manager** — user environment as NixOS module
- **systemd-boot** + Plymouth — silent boot with themed splash

## Hosts

| Host      | Role                | Notes                                   |
| --------- | ------------------- | --------------------------------------- |
| `desktop` | Primary workstation | 2560×1440@144, wired networking         |
| `laptop`  | Mobile machine      | TLP, touchpad gestures, WiFi, backlight |
| `vm`      | Test target         | QEMU + VIRGL, auto-login, no disko      |

## Install

1. Boot the NixOS minimal ISO
2. Connect to the internet
3. Enter a nix-shell with git: `nix-shell -p git`
4. Clone this repo: `git clone https://github.com/DevMozgus/nixos-configs.git && cd nixos-configs`
5. Identify the target disk: `lsblk`
6. Run the installer:

```bash
./install.sh desktop /dev/nvme0n1
```

7. Reboot, enter LUKS passphrase, log in as `nicola`
8. Verify: `sudo nixos-rebuild switch --flake .#desktop`

## VM Testing

```bash
nix run .#vm
```

Delete `vm.qcow2` to reset runtime state between tests.

## Structure

```
flake.nix              # Entry point: inputs, outputs, nixosConfigurations
hosts/
  common/global/       # Shared NixOS modules (nix, locale, users, boot)
  common/optional/     # Opt-in modules (hyprland, audio, bluetooth, docker)
  desktop/             # Desktop host + disko config
  laptop/              # Laptop host + disko config
  vm/                  # QEMU VM host
home/
  common/              # Shared home-manager modules
    hyprland/          # Compositor config (shared + laptop-specific)
    waybar/            # Status bar with conditional laptop modules
  desktop.nix          # Desktop HM entry point
  laptop.nix           # Laptop HM entry point
themes/                # Base16 color scheme YAML
assets/                # Wallpaper (add wallpaper.png here)
pkgs/                  # Custom derivations (Plymouth theme)
overlays/              # nix-vscode-extensions + NUR + custom pkgs
```

## Notes

- Run `git add -A` before `nixos-rebuild` — flakes only evaluate tracked files
- `hardware-configuration.nix` is generated per-machine with `nixos-generate-config --no-filesystems`
- Add your wallpaper as `assets/wallpaper.png` (any 1920×1080+ PNG)

## Netbird — post-install setup

1. After rebuilding, authenticate the peer:
   ```bash
   netbird-wt0 login
   ```
2. Verify the connection:
   ```bash
   netbird-wt0 status
   ```

## 1Password — post-install setup

1. **Enable the SSH agent** — open 1Password → Settings → Developer → check _Use the SSH agent_
2. **Add your SSH signing key** — in 1Password, create or import the SSH key you want to use for Git signing
3. **Set the signing key in git config** — edit `home/common/git.nix` and add the public key:
   ```nix
   user.signingKey = "ssh-ed25519 AAAA...";
   ```
   You can retrieve the public key after enabling the agent with:
   ```bash
   ssh-add -L
   ```
4. Rebuild and switch: `git add -A && sudo nixos-rebuild switch --flake .#<hostname>`

## Opencode - post-install setup

1. Authenticate in opencode with `/connect` (in opencode CLI)
2. Authenticate plugin with `opencode auth login` in terminal
3. Test if it works with `ping all agentst` (in opencode CLI)
