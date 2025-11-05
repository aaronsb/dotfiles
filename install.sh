#!/bin/bash

# Install script for dotfiles management tool

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_SCRIPT="$DOTFILES_DIR/dotfiles"
LOCAL_BIN="$HOME/.local/bin"

echo "Installing dotfiles management tool..."

# Create ~/.local/bin if it doesn't exist
if [[ ! -d "$LOCAL_BIN" ]]; then
    mkdir -p "$LOCAL_BIN"
    echo "Created $LOCAL_BIN"
fi

# Create symlink to dotfiles script
if [[ -L "$LOCAL_BIN/dotfiles" ]]; then
    rm "$LOCAL_BIN/dotfiles"
fi

ln -s "$DOTFILES_SCRIPT" "$LOCAL_BIN/dotfiles"
echo "Created symlink: $LOCAL_BIN/dotfiles -> $DOTFILES_SCRIPT"

# Check if ~/.local/bin is in PATH
if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
    echo
    echo "WARNING: $LOCAL_BIN is not in your PATH"
    echo "Add this line to your shell config (.zshrc or .bashrc):"
    echo "  export PATH=\"\$HOME/.local/bin:\$PATH\""
else
    echo
    echo "Installation complete! You can now use 'dotfiles' from anywhere."
fi

echo
echo "Run 'dotfiles help' to get started."