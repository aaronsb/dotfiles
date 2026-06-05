# Dotfiles

Personal configuration files managed with a custom dotfiles management tool.

Yes I know it's silly that it's called dotfiles, with a .

## 🚀 Bootstrap on a New Machine

One-liner (clone, then run the bootstrap that lives in the clone):

```bash
git clone https://github.com/aaronsb/dotfiles.git ~/.dotfiles && ~/.dotfiles/bootstrap.sh
```

> Not `curl | bash`: bootstrap **must** run from inside the clone (the
> `dotfiles` command is a symlink back into the repo), and cloning first gives
> you a repo you can inspect. Assumes `~/.dotfiles` doesn't already exist.

Or step by step:

```bash
git clone https://github.com/aaronsb/dotfiles.git ~/.dotfiles
~/.dotfiles/bootstrap.sh   # interactive setup
source ~/.zshrc            # reload your shell
```

The bootstrap script will:
- Install the `dotfiles` command (via `dotfiles install`)
- Show current status
- Offer to deploy configs (with preview option)

Already cloned and just need the command on a new shell? Run
`~/.dotfiles/dotfiles install` directly.

## 📋 Daily Commands

```bash
dotfiles status     # What's deployed?
dotfiles list       # What's managed?
```

Since everything deploys as symlinks, editing either `~/.tmux.conf` or
`~/.dotfiles/tmux/.tmux.conf` edits the same file — `git status` in
`~/.dotfiles` is your source of truth for "what changed".

## 🛠️ All Commands

**Configs (symlink layer)**

| Command | Description | Example |
|---------|-------------|---------|
| `status` | Show what's deployed vs available | `dotfiles status` |
| `deploy` | Create symlinks to activate configs | `dotfiles deploy --dry-run` |
| `add` | Add new app to management | `dotfiles add nvim .config/nvim` |
| `enable` | Enable a disabled config | `dotfiles enable vim` |
| `disable` | Temporarily disable a config | `dotfiles disable tmux` |
| `list` | Show all managed configs | `dotfiles list` |

**Sync (git layer)**

| Command | Description | Example |
|---------|-------------|---------|
| `diff` | Preview local state vs origin | `dotfiles diff --details` |
| `pull` | Fast-forward pull from origin | `dotfiles pull` |
| `push` | Commit + push to origin | `dotfiles push -m "tmux: ..."` |

**Lifecycle (tool layer)**

| Command | Description | Example |
|---------|-------------|---------|
| `install` | Symlink the command into `~/.local/bin` | `./dotfiles install` |
| `update` | Pull latest (self-updates the tool) + re-deploy | `dotfiles update` |
| `remove` | Remove the command symlink (configs stay) | `dotfiles remove` |
| `help` | Open the full manual | `dotfiles help` |

**Packages (system layer)**

| Command | Description | Example |
|---------|-------------|---------|
| `pkg capture` | Record this host's explicit packages | `dotfiles pkg capture` |
| `pkg status` | Show package drift (tracked vs installed) | `dotfiles pkg status` |
| `pkg sync` | Install tracked-but-missing (`--prune` removes extras) | `dotfiles pkg sync` |

Run `dotfiles help` for the full manual.

## 📁 Directory Structure

```
~/.dotfiles/
├── dotfiles           # Entry point: loads lib/ modules, then dispatches
├── lib/               # Command modules sourced by `dotfiles`
│   ├── common.sh      #   colors, logging, manifest helpers
│   ├── configs.sh     #   status/deploy/enable/disable/add/list
│   ├── git.sh         #   diff/pull/push
│   ├── pkg.sh         #   package tracking (pacman/AUR/flatpak)
│   └── lifecycle.sh   #   install/update/remove + self-update check
├── bootstrap.sh       # New machine entry point (calls `dotfiles install`)
├── install.sh         # Thin wrapper → `dotfiles install`
├── HELP.md            # Full manual (rendered by `dotfiles help`)
├── .dotfiles-manifest # Tracking what's managed
├── CLAUDE.md          # AI assistant instructions
├── readme.md          # This file
│
├── tmux/
│   └── .tmux.conf    # → ~/.tmux.conf
├── zsh/
│   ├── .zshrc        # → ~/.zshrc
│   └── .zsh/         # → ~/.zsh (conf.d fragments + host.d/ per-host)
├── oh-my-posh/       # → ~/.config/oh-my-posh/* and ~/.local/bin/posh-theme
├── nvim/             # → ~/.config/nvim
└── packages/         # Per-host package lists (pkg subsystem, not symlinked)
    └── <hostname>/   #   native.txt · aur.txt · flatpak.txt
```

## 💡 Helpful Reminders

### Making Changes
1. **Edit in either location** - Changes to `~/.tmux.conf` or `~/.dotfiles/tmux/.tmux.conf` affect both
2. **Test before committing** - Make sure your changes work!
3. **Use descriptive commits** - Future you will thank present you

### Good Git Commit Messages
```bash
# Format: <app>: <what changed and why>

git add tmux/.tmux.conf
git commit -m "tmux: Add weather widget to status bar

- Shows current temperature and conditions
- Updates every 30 minutes
- Only active when online"
```

### Adding New Tools
```bash
# Example: Add neovim config
dotfiles add nvim .config/nvim

# This will:
# 1. Add to manifest
# 2. Create directory structure
# (drop existing config files into nvim/ yourself before deploying)

# Then commit:
git add nvim/ .dotfiles-manifest
git commit -m "nvim: Add initial neovim configuration

- Based on kickstart.nvim
- Includes LSP for Python and Go
- Custom keybindings for navigation"
```

### Syncing Changes

The tool wraps git so you don't drop to raw commands:

```bash
# Push your changes (prompts for a commit message)
dotfiles push
dotfiles push -m "tmux: add weather widget"   # one-shot, no prompts

# On another machine — pull + re-deploy in one step
dotfiles update            # self-updates the tool, then deploys configs

# Or preview/pull manually
dotfiles diff --details    # what would pull/push do?
dotfiles pull              # fast-forward only
dotfiles deploy            # symlink any new configs
```

Because the `dotfiles` command is itself a symlink into the repo, `pull`/`update`
upgrade the tool transparently — `update` reports the version bump so it's not a
silent change. Every command also nudges you when the repo is behind origin
(disable with `DOTFILES_NO_UPDATE_CHECK=1`).

### Tracking Packages (Arch family)

Record what's explicitly installed per host, so a rebuild is reproducible:

```bash
dotfiles pkg status        # drift: tracked vs actually installed
dotfiles pkg capture       # write live state → packages/<host>/*.txt
dotfiles push              # commit the lists

# On a new machine, after pulling:
dotfiles pkg sync          # install tracked-but-missing (additive)
dotfiles pkg sync --prune  # also remove untracked (sharper edge)
```

Sources (native/AUR/flatpak) absent on a host are skipped, not errored. See
`dotfiles help` for details.

## 🔧 How It Works

The system uses **symbolic links** (symlinks):
- Real files live in `~/.dotfiles/<app>/`
- System locations have symlinks pointing to these files
- Git tracks the real files in the repo
- Changes anywhere affect both locations

Example:
```
~/.tmux.conf → ~/.dotfiles/tmux/.tmux.conf
     ↑                      ↑
  symlink              real file
```

## 🆘 Troubleshooting

### Command not found
```bash
# Make sure ~/.local/bin is in PATH
echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc
source ~/.zshrc
```

### Deployment conflicts
```bash
# See what's blocking
dotfiles status

# Force deploy with backups
dotfiles deploy --force

# Check backups if needed
ls ~/.dotfiles-backup/
```

### Accidental changes
```bash
# See what changed (configs are symlinks, so git in the repo tells you)
cd ~/.dotfiles && git status && git diff

# Restore from repo
git checkout -- <file>

# Or restore from a deploy backup
cp ~/.dotfiles-backup/.tmux.conf.20240315_142035 ~/.tmux.conf
```

## 📝 Notes for Future Me

- **Commit often** - Small, focused changes are easier to understand
- **Document weird configs** - Add comments explaining non-obvious settings
- **Test on fresh systems** - Spin up a VM occasionally to test bootstrap
- **Review old configs** - `git log --grep="tmux"` to see evolution
- **Keep it simple** - Resist the urge to over-engineer
