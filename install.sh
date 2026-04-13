#!/usr/bin/env bash
# =============================================================================
# install.sh — run from the NixOS minimal ISO to install from this flake
# Usage:
#   bash <(curl -sL https://raw.githubusercontent.com/YOUR_USER/nixos-config/main/install.sh)
# =============================================================================
set -euo pipefail

FLAKE_REPO="git@github.com:ndoshom/nixos-config.git"   # ← replace
FLAKE_DIR="/tmp/nixos-config"
TARGET_DISK="/dev/sda"    # ← confirm before running!
HOST="${1:-server}"       # pass 'desktop' as first arg for desktop install

echo "==> Installing NixOS host: $HOST onto $TARGET_DISK"
echo "==> Press Ctrl-C within 5s to abort..."
sleep 5

# 1. Ensure nix flakes are available
export NIX_CONFIG="experimental-features = nix-command flakes"

# 2. Install git if missing
nix-env -iA nixos.git 2>/dev/null || true

# 3. Clone the flake
rm -rf "$FLAKE_DIR"
git clone "$FLAKE_REPO" "$FLAKE_DIR"

# 4. Partition & format with disko
nix run github:nix-community/disko -- \
  --mode disko \
  "$FLAKE_DIR/hosts/$HOST/disko.nix"

# 5. Generate hardware-configuration.nix and drop it into the flake
nixos-generate-config --root /mnt --no-filesystems
cp /mnt/etc/nixos/hardware-configuration.nix "$FLAKE_DIR/hosts/$HOST/"

# 6. Install
nixos-install \
  --root /mnt \
  --flake "$FLAKE_DIR#$HOST" \
  --no-root-passwd

# 7. Copy flake to /mnt/etc/nixos so rebuilds work out of the box
mkdir -p /mnt/etc/nixos
cp -r "$FLAKE_DIR/." /mnt/etc/nixos/

echo ""
echo "==> Installation complete! Set your password with:"
echo "    nixos-enter --root /mnt -- passwd ns"
echo "==> Then: reboot"
