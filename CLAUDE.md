# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Overview

This is a dotfiles repository for managing configuration files across machines. It includes a custom `dotfiles` management tool that handles deployment via symlinks, capturing configs, and tracking changes.

## Directory Structure

- `dotfiles` - Main management script (the heart of the system)
- `bootstrap.sh` - Initial setup script for new machines
- `install.sh` - Quick installer for the dotfiles command
- `.dotfiles-manifest` - Tracks which dotfiles are managed
- `tmux/` - Tmux terminal multiplexer configuration
- `zsh/` - Z shell configuration
- `vim/` - Vim editor configuration (when added)

## Dotfiles Management Commands

- `dotfiles status` - Check deployment state
- `dotfiles deploy [--dry-run] [--force]` - Deploy configs via symlinks
- `dotfiles capture [app]` - Copy configs from system to repo
- `dotfiles diff [app]` - Compare repo vs system versions
- `dotfiles add <app> <path>` - Add new config to management
- `dotfiles enable/disable <app>` - Toggle specific configs
- `dotfiles list` - Show all managed configs

## Git Commit Guidelines

When committing changes to dotfiles, use descriptive messages that explain:
1. **What changed** - Which config file(s) were modified
2. **Why it changed** - The reason or problem being solved
3. **Impact** - How it affects usage or behavior

### Good Commit Examples:
```
tmux: Add vim-style pane navigation with Ctrl+hjkl

- Enables seamless navigation between tmux panes using vim keys
- Maintains consistency with vim muscle memory
- Preserves existing arrow key bindings as fallback

zsh: Configure oh-my-posh with atomic theme

- Adds modern prompt with git status indicators
- Shows execution time for long-running commands
- Includes Python virtual env detection

dotfiles: Add capture --dry-run mode for safety

- Allows previewing which files would be captured
- Prevents accidental overwrites in the repository
- Matches deploy command's --dry-run pattern
```

### Bad Commit Examples:
```
update tmux config
fix stuff
changes
```

## Adding New Configurations

When adding a new tool's configuration:

1. Use `dotfiles add` command:
   ```bash
   # For simple files (symlink mode - default)
   dotfiles add nvim .config/nvim

   # For directories that need full copy (like nested git repos)
   dotfiles add some-tool .config/some-tool some-tool copy
   ```

2. This will:
   - Add entry to manifest
   - Prompt to capture existing config (symlink mode only)
   - Create appropriate directory structure

3. Commit with clear message:
   ```
   nvim: Add Neovim configuration with LSP support

   - Includes language servers for Python, JS, and Go
   - Sets up telescope for fuzzy finding
   - Configures gruvbox colorscheme
   ```

## Deployment Modes

The dotfiles system supports two deployment modes:

### Symlink Mode (Default)
- Creates symbolic links from `~/.config` to the dotfiles repo
- Changes in either location are immediately reflected
- Best for: individual config files, most dotfiles

### Copy Mode
- Recursively copies entire directories to `~/.config`
- Preserves `.git` directories for git repositories
- Automatically updates via `git pull` if target is a git repo
- Sets executable permissions on shell scripts
- Best for: git repositories, complex directory structures

## Testing Changes

Before committing configuration changes:

1. Test the actual application with the new config
2. Run `dotfiles status` to ensure proper deployment
3. Use `dotfiles diff` to review changes
4. Consider impacts on other systems/platforms

## Platform Considerations

- Note platform-specific settings in commit messages
- Use conditional logic in configs when possible
- Document any OS-specific requirements

## Backup and Recovery

The dotfiles tool automatically backs up existing configs when deploying with `--force`. Backups are stored in `~/.dotfiles-backup/` with timestamps.

To recover from a bad config:
1. Check backups in `~/.dotfiles-backup/`
2. Manually restore or use `dotfiles disable <app>` then copy back
3. Re-deploy when ready

## Evolution Tracking

Since dotfiles evolve over time, good commit messages help track:
- When features were added/removed
- Why certain decisions were made  
- What problems were being solved
- Which tools influenced changes

Use `git log --grep` to search history, e.g.:
```bash
git log --grep="tmux" --oneline  # All tmux-related changes
git log --grep="vim.*navigation"  # Vim navigation updates
```