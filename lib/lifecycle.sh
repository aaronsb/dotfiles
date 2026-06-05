# lib/lifecycle.sh — tool lifecycle: install/update/remove + self-update detection.
# Sourced by ../dotfiles.

# ============================================================================
# Lifecycle (install / update / remove) + self-update detection
#
# The `dotfiles` command in ~/.local/bin is a symlink INTO this repo, so a
# git pull of the repo updates the tool itself transparently. These verbs make
# that lifecycle explicit:
#   install — symlink the command into ~/.local/bin (self-install from a clone)
#   update  — pull (self-updates the script via the symlink) + re-deploy configs
#   remove  — remove the command symlink (configs and repo are left intact)
# A lightweight check on every run nudges you when the repo is behind origin.
# ============================================================================

LOCAL_BIN="$HOME/.local/bin"
DOTFILES_CMD_LINK="$LOCAL_BIN/dotfiles"

# Non-blocking "you're behind origin" nudge. Skipped on non-tty, when disabled,
# off-main, or without a usable remote. Network fetch is throttled to once/day
# via a stamp file so normal commands stay fast and work offline.
check_for_update() {
    [[ -t 1 ]] || return 0
    [[ -n "${DOTFILES_NO_UPDATE_CHECK:-}" ]] && return 0
    git -C "$DOTFILES_DIR" rev-parse --git-dir &>/dev/null || return 0
    git -C "$DOTFILES_DIR" remote get-url origin &>/dev/null || return 0
    [[ "$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref HEAD)" == "main" ]] || return 0

    local stamp="$HOME/.cache/dotfiles/last-check" now last=0 age
    # This runs on the happy path of every command, so it must never abort it:
    # guard the cache dir (read-only home) and stamp the *attempt* (not just a
    # successful fetch) so an offline host doesn't re-fetch on every invocation.
    mkdir -p "$(dirname "$stamp")" 2>/dev/null || return 0
    now="$(date +%s)"
    [[ -f "$stamp" ]] && last="$(date -r "$stamp" +%s 2>/dev/null || echo 0)"
    age=$(( now - last ))
    if (( age >= 86400 )); then
        git -C "$DOTFILES_DIR" fetch origin main --quiet 2>/dev/null || true
        touch "$stamp" 2>/dev/null || true
    fi

    local behind
    behind="$(git -C "$DOTFILES_DIR" rev-list --count HEAD..origin/main 2>/dev/null || echo 0)"
    if (( behind > 0 )); then
        log_warning "dotfiles is $behind commit(s) behind origin/main — run 'dotfiles update' to update the tool and configs."
    fi
}

# Install command - symlink this script into ~/.local/bin (self-install).
cmd_install() {
    echo -e "${CYAN}=== Installing dotfiles command ===${NC}"
    echo
    mkdir -p "$LOCAL_BIN"
    # -f replaces any existing link atomically; -n avoids descending into a
    # symlink-to-directory target. Cleaner than a non-atomic rm + ln.
    ln -sfn "$SCRIPT_PATH" "$DOTFILES_CMD_LINK"
    log_success "Linked: $DOTFILES_CMD_LINK → $SCRIPT_PATH"
    if [[ ":$PATH:" != *":$LOCAL_BIN:"* ]]; then
        log_warning "$LOCAL_BIN is not on your PATH. Add to your shell config:"
        echo "    export PATH=\"\$HOME/.local/bin:\$PATH\""
    fi
    echo
    log_info "Next: 'dotfiles deploy' to symlink your configs, or 'dotfiles help'."
}

# Update command - pull latest (self-updates the script) then re-deploy configs.
# Always targets main (the documented contract); no branch override.
#
# If the pull actually advanced HEAD, the deploy phase is run by re-exec'ing the
# freshly-pulled tool (`exec "$SCRIPT_PATH" deploy`) rather than the in-memory
# cmd_deploy. The running process still holds the OLD deploy logic — re-exec
# ensures post-update work runs under post-update code (new manifest handling,
# new configs, etc.), not just that it doesn't crash.
cmd_update() {
    require_git_remote || exit 1
    echo -e "${CYAN}=== Updating dotfiles ===${NC}"
    echo
    local before after
    before="$(git -C "$DOTFILES_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"

    cmd_pull

    after="$(git -C "$DOTFILES_DIR" rev-parse --short HEAD 2>/dev/null || echo unknown)"
    if [[ "$before" != "$after" ]]; then
        log_success "Tool updated: $before → $after"
        echo
        log_info "Re-executing the updated tool to deploy configs..."
        exec "$SCRIPT_PATH" deploy
    fi

    echo
    log_info "Already up to date — re-deploying configs..."
    cmd_deploy
    echo
    log_success "Update complete."
}

# Remove command - uninstall the command symlink only. Leaves deployed config
# symlinks and the repo untouched (re-install with: <repo>/dotfiles install).
cmd_remove() {
    echo -e "${CYAN}=== Removing dotfiles command ===${NC}"
    echo
    if [[ -L "$DOTFILES_CMD_LINK" ]]; then
        rm -f "$DOTFILES_CMD_LINK"
        log_success "Removed command symlink: $DOTFILES_CMD_LINK"
        log_info "Your deployed configs and the repo at $DOTFILES_DIR are untouched."
        log_info "Re-install anytime with: $SCRIPT_PATH install"
    else
        log_warning "No dotfiles command symlink at $DOTFILES_CMD_LINK — nothing to remove."
    fi
}
