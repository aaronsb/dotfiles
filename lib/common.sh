# lib/common.sh — colors, logging, and manifest helpers.
# Sourced by ../dotfiles; do not run directly.

# Colors for output
RED=$'\033[0;31m'
GREEN=$'\033[0;32m'
YELLOW=$'\033[0;33m'
BLUE=$'\033[0;34m'
PURPLE=$'\033[0;35m'
CYAN=$'\033[0;36m'
NC=$'\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Initialize manifest if it doesn't exist
init_manifest() {
    if [[ ! -f "$MANIFEST_FILE" ]]; then
        cat > "$MANIFEST_FILE" << EOF
# Dotfiles Manifest
# Format: app_name|source_path|target_path|enabled|deploy_type
# deploy_type: symlink (default) or copy (for directories that need full copy, like git repos)
tmux|tmux/.tmux.conf|.tmux.conf|true|symlink
zsh|zsh/.zshrc|.zshrc|true|symlink
vim|vim/.vimrc|.vimrc|true|symlink
EOF
        log_info "Created manifest file at $MANIFEST_FILE"
    fi
}

# Read manifest and return active entries
read_manifest() {
    grep -v '^#' "$MANIFEST_FILE" 2>/dev/null || true
}

# Check if a dotfile is deployed (symlinked)
is_deployed() {
    local target="$HOME/$1"
    [[ -L "$target" && "$(readlink "$target")" == "$DOTFILES_DIR/$2" ]]
}
