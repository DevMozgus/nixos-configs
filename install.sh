#!/usr/bin/env bash
# install.sh — One-command NixOS installer with disko + LUKS
set -euo pipefail

FLAKE_DIR="$(cd "$(dirname "$0")" && pwd)"

# --- Argument validation ---
if [[ $# -lt 2 ]]; then
  echo "Usage: $0 <hostname> <disk>"
  echo "  hostname: desktop | laptop"
  echo "  disk:     /dev/nvme0n1 | /dev/sda | ..."
  exit 1
fi

HOSTNAME="$1"
DISK="$2"

if [[ "$HOSTNAME" != "desktop" && "$HOSTNAME" != "laptop" ]]; then
  echo "Error: hostname must be 'desktop' or 'laptop'"
  exit 1
fi

if [[ ! -b "$DISK" ]]; then
  echo "Error: $DISK is not a valid block device"
  exit 1
fi

# --- Confirmation ---
echo "======================================"
echo "  NixOS Installer — $HOSTNAME"
echo "======================================"
echo ""
echo "Target disk: $DISK"
echo "Flake config: ${FLAKE_DIR}#${HOSTNAME}"
echo ""
echo "WARNING: ALL DATA ON $DISK WILL BE ERASED!"
echo ""
read -rp "Type 'yes' to continue: " CONFIRM
if [[ "$CONFIRM" != "yes" ]]; then
  echo "Aborted."
  exit 1
fi

# --- Password prompt ---
HASH_DIR="$(mktemp -d)"
HASH_FILE="${HASH_DIR}/nicola"
cleanup() { rm -rf "$HASH_DIR"; }
trap cleanup EXIT

while true; do
  echo ""
  read -rsp "Enter password for user 'nicola': " PASS1
  echo ""
  read -rsp "Confirm password: " PASS2
  echo ""

  if [[ "$PASS1" == "$PASS2" ]]; then
    SALT=$(head -c 16 /dev/urandom | od -An -tx1 | tr -d ' \n' | head -c 16)
    HASH_FILE_CONTENT=$(perl -e '
      my $pass = $ARGV[0];
      my $salt = $ARGV[1];
      print crypt($pass, "\$6\$" . $salt . "\$") . "\n";
    ' "$PASS1" "$SALT")
    echo "$HASH_FILE_CONTENT" > "$HASH_FILE"
    echo "Password hashed successfully."
    break
  else
    echo "Passwords do not match. Try again."
  fi
done

# --- Ensure all files are tracked by git (flakes requirement) ---
echo ""
echo "Staging all files for flake evaluation..."
git -C "$FLAKE_DIR" add -A

# --- Step 1: Partition, format, and mount with disko ---
echo ""
echo "Running disko to partition and encrypt $DISK..."
echo "You will be prompted to set a LUKS passphrase."
echo ""

sudo nix \
  --extra-experimental-features "nix-command flakes" \
  run github:nix-community/disko/latest -- \
  --mode disko \
  --flake "${FLAKE_DIR}#${HOSTNAME}" \
  --disk main "$DISK"

# --- Step 2: Place the hashed password file ---
echo ""
echo "Copying password hash to /mnt/persist/passwords/nicola..."
sudo install -Dm400 "$HASH_FILE" /mnt/persist/passwords/nicola

# --- Step 3: Install NixOS ---
echo ""
echo "Running nixos-install..."
echo ""

sudo nixos-install \
  --no-root-password \
  --flake "${FLAKE_DIR}#${HOSTNAME}" \
  --option extra-substituters "https://hyprland.cachix.org https://nix-community.cachix.org" \
  --option extra-trusted-public-keys "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc= nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCUSeBc="

echo ""
echo "======================================"
echo "  Installation complete!"
echo "======================================"
echo ""
echo "Next steps:"
echo "  1. Remove the install media"
echo "  2. Reboot"
echo "  3. Enter your LUKS passphrase at boot"
echo "  4. Log in as 'nicola'"
echo "  5. Clone this repo to ~/nixos-config"
echo "  6. Run: sudo nixos-rebuild switch --flake .#${HOSTNAME}"
echo ""
