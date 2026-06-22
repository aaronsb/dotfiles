#!/bin/bash

# Install the dotfiles tooling:
#   - the Rust `dotfiles` CLI (prebuilt binary) as the primary command, and
#   - the legacy bash tool as `dotfiles-bash`, a fallback for verbs not yet
#     ported (e.g. the lifecycle/update niceties).
#
# The Rust CLI reads the rich TOML manifest (.dotfiles-manifest.toml); the bash
# fallback reads the legacy pipe `.dotfiles-manifest`. Both are kept in sync
# during convergence.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOCAL_BIN="$HOME/.local/bin"
mkdir -p "$LOCAL_BIN"

echo "Installing the Rust 'dotfiles' CLI (prebuilt binary)..."
curl -fsSL https://raw.githubusercontent.com/aaronsb/dotfiles-cli/main/install.sh | bash

echo
echo "Linking the bash fallback as 'dotfiles-bash'..."
ln -sfn "$DOTFILES_DIR/dotfiles-bash" "$LOCAL_BIN/dotfiles-bash"

echo
echo "Done: 'dotfiles' = Rust CLI, 'dotfiles-bash' = legacy fallback."
echo "Next: 'dotfiles deploy' to symlink your configs."
