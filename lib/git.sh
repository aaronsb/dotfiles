# lib/git.sh — git sync layer: flag parsing, branch/remote guards, diff/pull/push.
# Sourced by ../dotfiles.

# Parse common flags from args.
# Sets globals: TARGET_BRANCH (default "main"), DETAILS (default false), MESSAGE (default "").
parse_flags() {
    TARGET_BRANCH="main"
    DETAILS=false
    MESSAGE=""
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --branch|-b)
                shift
                TARGET_BRANCH="${1:-}"
                [[ -z "$TARGET_BRANCH" ]] && { log_error "--branch requires a name."; exit 1; }
                shift
                ;;
            --details|-d)
                DETAILS=true
                shift
                ;;
            --message|-m)
                shift
                MESSAGE="${1:-}"
                [[ -z "$MESSAGE" ]] && { log_error "--message requires a value."; exit 1; }
                shift
                ;;
            *)
                shift
                ;;
        esac
    done
}

# Require the working tree to be on $1, otherwise bail with hints.
require_on_branch() {
    local target="$1"
    local current
    current="$(git -C "$DOTFILES_DIR" rev-parse --abbrev-ref HEAD)"
    if [[ "$current" != "$target" ]]; then
        log_error "Currently on '$current', not '$target'."
        log_info "Switch:    git -C $DOTFILES_DIR checkout $target"
        log_info "Or target current branch: dotfiles ${FUNCNAME[1]#cmd_} --branch $current"
        exit 1
    fi
}

# Verify the dotfiles dir is a git repo with an 'origin' remote.
# Returns 0 if usable, 1 with a printed reason if not.
require_git_remote() {
    if ! git -C "$DOTFILES_DIR" rev-parse --git-dir &>/dev/null; then
        log_error "$DOTFILES_DIR is not a git repository."
        log_info "Initialize it with: git -C $DOTFILES_DIR init"
        return 1
    fi
    if ! git -C "$DOTFILES_DIR" remote get-url origin &>/dev/null; then
        log_error "No 'origin' remote configured in $DOTFILES_DIR."
        log_info "Add one with: git -C $DOTFILES_DIR remote add origin <url>"
        return 1
    fi
    return 0
}

# Diff command - show local state vs origin/<target> (preview before pull/push)
cmd_diff() {
    require_git_remote || exit 1
    parse_flags "$@"
    local target="$TARGET_BRANCH"

    log_info "Fetching from origin..."
    git -C "$DOTFILES_DIR" fetch origin "$target" --quiet 2>/dev/null \
        || { log_error "Fetch failed (does origin/$target exist?)."; exit 1; }

    local remote_ref="origin/$target"

    local dirty
    dirty="$(git -C "$DOTFILES_DIR" status --porcelain)"
    if [[ -n "$dirty" ]]; then
        echo "${YELLOW}Uncommitted changes:${NC}"
        echo "$dirty" | sed 's/^/    /'
        echo
        if $DETAILS; then
            git -C "$DOTFILES_DIR" diff --color=always
            git -C "$DOTFILES_DIR" diff --cached --color=always
        fi
    fi

    if ! git -C "$DOTFILES_DIR" rev-parse --verify "$remote_ref" &>/dev/null; then
        log_warning "$remote_ref does not exist."
        return 0
    fi

    local ahead behind
    ahead="$(git -C "$DOTFILES_DIR" rev-list --count "$remote_ref..HEAD")"
    behind="$(git -C "$DOTFILES_DIR" rev-list --count "HEAD..$remote_ref")"

    if [[ "$ahead" -eq 0 && "$behind" -eq 0 && -z "$dirty" ]]; then
        log_success "HEAD is in sync with $remote_ref."
        return 0
    fi

    if [[ "$ahead" -gt 0 ]]; then
        echo "${CYAN}Local is $ahead commit(s) ahead of $remote_ref (would push):${NC}"
        git -C "$DOTFILES_DIR" log --oneline "$remote_ref..HEAD" | sed 's/^/    /'
        if $DETAILS; then
            git -C "$DOTFILES_DIR" diff --color=always "$remote_ref..HEAD"
        else
            git -C "$DOTFILES_DIR" diff --stat "$remote_ref..HEAD" | sed 's/^/    /'
        fi
        echo
    fi

    if [[ "$behind" -gt 0 ]]; then
        echo "${CYAN}Remote is $behind commit(s) ahead (would pull):${NC}"
        git -C "$DOTFILES_DIR" log --oneline "HEAD..$remote_ref" | sed 's/^/    /'
        if $DETAILS; then
            git -C "$DOTFILES_DIR" diff --color=always "HEAD..$remote_ref"
        else
            git -C "$DOTFILES_DIR" diff --stat "HEAD..$remote_ref" | sed 's/^/    /'
        fi
        echo
    fi
}

# Pull command - fast-forward pull from origin/<target> into local <target>
cmd_pull() {
    require_git_remote || exit 1
    parse_flags "$@"
    local target="$TARGET_BRANCH"
    require_on_branch "$target"

    log_info "Fetching origin/$target..."
    git -C "$DOTFILES_DIR" fetch origin "$target" --quiet \
        || { log_error "Fetch failed (does origin/$target exist?)."; exit 1; }

    local remote_ref="origin/$target"
    local behind
    behind="$(git -C "$DOTFILES_DIR" rev-list --count "HEAD..$remote_ref")"
    if [[ "$behind" -eq 0 ]]; then
        log_success "Already up to date with $remote_ref."
        return 0
    fi

    local old_head
    old_head="$(git -C "$DOTFILES_DIR" rev-parse HEAD)"

    if ! git -C "$DOTFILES_DIR" merge --ff-only "$remote_ref" --quiet; then
        log_error "Pull failed (likely diverged). Resolve manually."
        exit 1
    fi

    log_success "Pulled $behind commit(s) from $remote_ref:"
    git -C "$DOTFILES_DIR" log --oneline "$old_head..HEAD" | sed 's/^/    /'
    echo
    log_info "Files changed:"
    git -C "$DOTFILES_DIR" diff --stat "$old_head..HEAD" | sed 's/^/    /'
}

# Push command - commit (with prompt) and push current branch to origin/<target>
cmd_push() {
    require_git_remote || exit 1
    parse_flags "$@"
    local target="$TARGET_BRANCH"
    require_on_branch "$target"

    local dirty
    dirty="$(git -C "$DOTFILES_DIR" status --porcelain)"
    if [[ -n "$dirty" ]]; then
        log_info "Uncommitted changes:"
        echo "$dirty" | sed 's/^/    /'
        echo

        local message="$MESSAGE" do_commit=false
        if [[ -n "$message" ]]; then
            do_commit=true
        else
            read -rp "Commit these? [y/N] " -n 1 reply; echo
            if [[ $reply =~ ^[Yy]$ ]]; then
                read -rp "What changed? " message
                if [[ -z "$message" ]]; then
                    log_error "Empty message — aborted."
                    exit 1
                fi
                do_commit=true
            fi
        fi

        if $do_commit; then
            git -C "$DOTFILES_DIR" add -A
            git -C "$DOTFILES_DIR" commit -m "$message" || { log_error "Commit failed."; exit 1; }
            log_success "Committed: $message"
        else
            log_warning "Skipping commit — uncommitted changes will NOT be pushed."
        fi
    fi

    local remote_ref="origin/$target"

    if ! git -C "$DOTFILES_DIR" rev-parse --verify "$remote_ref" &>/dev/null; then
        log_warning "$remote_ref does not exist on origin yet."
        read -rp "Create it (push -u)? [y/N] " -n 1 reply; echo
        [[ ! $reply =~ ^[Yy]$ ]] && { log_info "Aborted."; exit 0; }
        if git -C "$DOTFILES_DIR" push -u origin "$target"; then
            log_success "Pushed and set upstream to $remote_ref."
        else
            log_error "Push failed."
            exit 1
        fi
        return 0
    fi

    local ahead
    ahead="$(git -C "$DOTFILES_DIR" rev-list --count "$remote_ref..HEAD")"
    if [[ "$ahead" -eq 0 ]]; then
        log_success "Already up to date with $remote_ref."
        return 0
    fi

    log_info "Local '$target' is $ahead commit(s) ahead of $remote_ref:"
    git -C "$DOTFILES_DIR" log --oneline "$remote_ref..HEAD" | sed 's/^/    /'
    echo
    if [[ -z "$MESSAGE" ]]; then
        read -rp "Push these commits to $remote_ref? [y/N] " -n 1 reply; echo
        [[ ! $reply =~ ^[Yy]$ ]] && { log_info "Aborted."; exit 0; }
    fi

    if git -C "$DOTFILES_DIR" push origin "$target"; then
        log_success "Pushed."
    else
        log_error "Push failed."
        exit 1
    fi
}
