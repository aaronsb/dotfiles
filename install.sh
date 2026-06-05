#!/bin/bash

# Thin wrapper — the install logic now lives in the dotfiles tool itself
# (`dotfiles install`). Kept so existing muscle memory and docs still work.

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
exec "$DOTFILES_DIR/dotfiles" install
