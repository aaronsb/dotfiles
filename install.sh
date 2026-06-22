#!/bin/bash

# Install the dotfiles tooling: the Rust `dotfiles` CLI (prebuilt binary) as the
# sole command. It reads the TOML manifest (.dotfiles-manifest.toml).

set -euo pipefail

LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

echo "Installing the Rust 'dotfiles' CLI (prebuilt binary)..."
curl -fsSL https://raw.githubusercontent.com/aaronsb/dotfiles-cli/main/install.sh | bash

echo
echo "Done: 'dotfiles' installed."
echo "Next: 'dotfiles deploy' to symlink your configs."
