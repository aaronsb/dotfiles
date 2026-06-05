# lib/pkg.sh — package tracking subsystem (pacman / AUR / flatpak).
# Sourced by ../dotfiles.

# ============================================================================
# Package tracking (Arch family: pacman / AUR / flatpak)
#
# Tracks explicitly-installed packages per host under packages/<host>/.
# The committed lists are the desired state ("what should be"); a live query
# is the actual state ("what is"). Sources absent on a host are skipped, not
# errored — cube may have no flatpak, slab may have no AUR helper.
#   native.txt  = pacman -Qqen   (official repos)
#   aur.txt     = pacman -Qqem   (foreign / AUR / manual)
#   flatpak.txt = flatpak apps
# ============================================================================

PKG_SOURCES=(native aur flatpak)

# Short hostname (matches zsh host.d/ convention: ${HOST%%.*}).
# Overridable with `--host <name>` to inspect another machine's lists.
pkg_host() {
    echo "${PKG_HOST_OVERRIDE:-${HOSTNAME:-$(uname -n)}}" | cut -d. -f1
}

# First available AUR helper, or non-zero if none.
pkg_aur_helper() {
    local h
    for h in paru yay; do
        command -v "$h" &>/dev/null && { echo "$h"; return 0; }
    done
    return 1
}

# Is this source usable on the current machine?
pkg_source_available() {
    case "$1" in
        native)  command -v pacman  &>/dev/null ;;
        aur)     pkg_aur_helper &>/dev/null ;;
        flatpak) command -v flatpak &>/dev/null ;;
        *)       return 1 ;;
    esac
}

# Live (actual) explicitly-installed list for a source, sorted for stable diffs.
pkg_live_list() {
    case "$1" in
        native)  pacman -Qqen 2>/dev/null | sort ;;
        aur)     pacman -Qqem 2>/dev/null | sort ;;
        flatpak) flatpak list --app --columns=application 2>/dev/null | sort ;;
    esac
}

# Path to the tracked (desired) list file for a source on a given host.
pkg_file() {
    echo "$PACKAGES_DIR/$2/$1.txt"
}

# Tracked list for a source/host, sorted; empty if no file.
pkg_tracked_list() {
    local file; file="$(pkg_file "$1" "$2")"
    [[ -f "$file" ]] && sort "$file" || true
}

# Capture: write live state of every available source to packages/<host>/.
cmd_pkg_capture() {
    local host; host="$(pkg_host)"
    local dir="$PACKAGES_DIR/$host"
    echo -e "${CYAN}=== Capturing packages for '$host' ===${NC}"
    echo
    mkdir -p "$dir"

    local src captured=false
    for src in "${PKG_SOURCES[@]}"; do
        if ! pkg_source_available "$src"; then
            log_info "$src: not available here — skipped"
            continue
        fi
        local file; file="$(pkg_file "$src" "$host")"
        # Query into a var first: pacman -Qqem exits non-zero with no output
        # when a host has zero AUR packages. Writing the redirect directly
        # would truncate the file, then `set -e` would abort mid-capture.
        local listing count=0
        listing="$(pkg_live_list "$src")" || true
        if [[ -n "$listing" ]]; then
            printf '%s\n' "$listing" > "$file"
            count="$(printf '%s\n' "$listing" | wc -l | tr -d ' ')"
        else
            : > "$file"   # source present but genuinely empty → empty list
        fi
        log_success "$src: wrote $count package(s) → packages/$host/$src.txt"
        captured=true
    done

    echo
    if $captured; then
        log_info "Review with 'git diff', then 'dotfiles push' to record."
    else
        log_warning "No supported package managers found on this host."
    fi
}

# Status: per-source drift between tracked (desired) and live (actual).
# A live diff only makes sense on the host itself; for a remote host
# (--host other) we can only show the tracked/desired lists.
cmd_pkg_status() {
    local host; host="$(pkg_host)"
    local is_local=true
    [[ "$host" != "$(echo "${HOSTNAME:-$(uname -n)}" | cut -d. -f1)" ]] && is_local=false
    echo -e "${CYAN}=== Package status for '$host' ===${NC}"
    $is_local || echo -e "${YELLOW}(remote host — showing tracked lists only, no live diff)${NC}"
    echo

    local src any=false
    # Remote host: report tracked desired state, skip live queries entirely.
    if ! $is_local; then
        for src in "${PKG_SOURCES[@]}"; do
            local file; file="$(pkg_file "$src" "$host")"
            [[ ! -f "$file" ]] && continue
            any=true
            log_info "$src: $(wc -l < "$file" | tr -d ' ') tracked package(s)"
        done
        echo
        $any || log_warning "No tracked lists for '$host' yet — run 'dotfiles pkg capture' on it."
        return 0
    fi

    for src in "${PKG_SOURCES[@]}"; do
        local file; file="$(pkg_file "$src" "$host")"
        local available=true
        pkg_source_available "$src" || available=false

        # Nothing tracked and source absent → not relevant to this host.
        [[ ! -f "$file" ]] && ! $available && continue
        any=true

        if [[ ! -f "$file" ]]; then
            log_warning "$src: installed here but not tracked — run 'dotfiles pkg capture'"
            continue
        fi
        if ! $available; then
            log_info "$src: tracked, but $src not installed on this host"
            continue
        fi

        local tracked live missing extra
        tracked="$(pkg_tracked_list "$src" "$host")"
        live="$(pkg_live_list "$src")"
        missing="$(comm -23 <(echo "$tracked") <(echo "$live"))"
        extra="$(comm -13 <(echo "$tracked") <(echo "$live"))"

        if [[ -z "$missing" && -z "$extra" ]]; then
            log_success "$src: in sync"
            continue
        fi
        echo -e "${YELLOW}$src:${NC}"
        if [[ -n "$missing" ]]; then
            echo -e "  ${RED}tracked but not installed (sync installs):${NC}"
            echo "$missing" | sed 's/^/    + /'
        fi
        if [[ -n "$extra" ]]; then
            echo -e "  ${PURPLE}installed but not tracked (capture records / --prune removes):${NC}"
            echo "$extra" | sed 's/^/    - /'
        fi
    done

    echo
    $any || log_warning "No tracked lists or supported package managers for '$host'."
}

# Sync: install tracked-but-missing. With --prune, also remove untracked.
cmd_pkg_sync() {
    local prune=false
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --prune) prune=true; shift ;;
            *)       shift ;;
        esac
    done

    local host; host="$(pkg_host)"
    if [[ "$host" != "$(echo "${HOSTNAME:-$(uname -n)}" | cut -d. -f1)" ]]; then
        log_error "Refusing to sync: target host '$host' is not this machine."
        log_info "sync changes the live system, so it only runs against the local host."
        exit 1
    fi
    echo -e "${CYAN}=== Syncing packages for '$host' ===${NC}"
    echo

    local src acted=false
    for src in "${PKG_SOURCES[@]}"; do
        local file; file="$(pkg_file "$src" "$host")"
        [[ ! -f "$file" ]] && continue
        if ! pkg_source_available "$src"; then
            log_warning "$src: tracked but $src not installed here — skipped"
            continue
        fi

        local tracked live missing extra
        tracked="$(pkg_tracked_list "$src" "$host")"
        live="$(pkg_live_list "$src")"
        missing="$(comm -23 <(echo "$tracked") <(echo "$live"))"
        extra="$(comm -13 <(echo "$tracked") <(echo "$live"))"

        if [[ -n "$missing" ]]; then
            acted=true
            log_info "$src: installing $(echo "$missing" | grep -c .) missing package(s)..."
            pkg_install "$src" "$missing"
        fi
        if $prune && [[ -n "$extra" ]]; then
            acted=true
            log_warning "$src: removing $(echo "$extra" | grep -c .) untracked package(s)..."
            pkg_remove "$src" "$extra"
        fi
    done

    echo
    $acted && log_success "Sync complete." || log_success "Nothing to do — already in sync."
}

# Install a newline-delimited package set for a source (additive).
# Pass names as argv via `xargs -a <(...)` rather than piping into `-`:
# piping consumes stdin, so pacman/yay can't reopen it for the [Y/n]
# prompt ("failed to reopen stdin"). -a keeps the command's stdin on the
# terminal so the confirmation still works.
pkg_install() {
    local src="$1" pkgs="$2"
    case "$src" in
        native)  xargs -r -a <(printf '%s\n' "$pkgs") sudo pacman -S --needed ;;
        aur)     xargs -r -a <(printf '%s\n' "$pkgs") "$(pkg_aur_helper)" -S --needed ;;
        flatpak) xargs -r -a <(printf '%s\n' "$pkgs") flatpak install -y "${FLATPAK_REMOTE:-flathub}" ;;
    esac
}

# Remove a newline-delimited package set for a source.
# Same -a rationale as pkg_install: `pacman -Rns` prompts for confirmation,
# so its stdin must stay on the terminal, not the package-list pipe.
# Note: -Rns also removes now-orphaned dependencies and config (.pacsave),
# so the blast radius can exceed the listed packages — confirm at the prompt.
pkg_remove() {
    local src="$1" pkgs="$2"
    case "$src" in
        native|aur) xargs -r -a <(printf '%s\n' "$pkgs") sudo pacman -Rns ;;
        flatpak)    xargs -r -a <(printf '%s\n' "$pkgs") flatpak uninstall ;;
    esac
}

# Package command dispatcher.
cmd_pkg() {
    local sub="${1:-status}"
    [[ $# -gt 0 ]] && shift
    # Pull an optional --host <name> out of the remaining args.
    local rest=()
    while [[ $# -gt 0 ]]; do
        case "$1" in
            --host)
                [[ -z "${2:-}" ]] && { log_error "--host requires a hostname"; exit 1; }
                PKG_HOST_OVERRIDE="$2"; shift 2 ;;
            *)      rest+=("$1"); shift ;;
        esac
    done
    case "$sub" in
        capture) cmd_pkg_capture "${rest[@]}" ;;
        status)  cmd_pkg_status  "${rest[@]}" ;;
        sync)    cmd_pkg_sync    "${rest[@]}" ;;
        *)       log_error "Unknown pkg subcommand: $sub"; echo
                 log_info "Try: dotfiles pkg [capture|status|sync] [--host <name>] [--prune]"
                 exit 1 ;;
    esac
}
