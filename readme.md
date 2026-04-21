# Dotfiles

Personal configuration files managed with a custom dotfiles management tool.

Yes I know it's silly that it's called dotfiles, with a .

## 🚀 Bootstrap on a New Machine

```bash
# 1. Clone your dotfiles repo
git clone https://github.com/yourusername/dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# 2. Run the bootstrap script (interactive setup)
./bootstrap.sh

# 3. Reload your shell
source ~/.zshrc  # or ~/.bashrc
```

The bootstrap script will:
- Install the `dotfiles` command
- Show current status
- Offer to deploy configs (with preview option)
- Set up everything needed

## 📋 Daily Commands

```bash
dotfiles status     # What's deployed?
dotfiles list       # What's managed?
```

Since everything deploys as symlinks, editing either `~/.tmux.conf` or
`~/.dotfiles/tmux/.tmux.conf` edits the same file — `git status` in
`~/.dotfiles` is your source of truth for "what changed".

## 🛠️ All Commands

| Command | Description | Example |
|---------|-------------|---------|
| `status` | Show what's deployed vs available | `dotfiles status` |
| `deploy` | Create symlinks to activate configs | `dotfiles deploy --dry-run` |
| `add` | Add new app to management | `dotfiles add nvim .config/nvim` |
| `enable` | Enable a disabled config | `dotfiles enable vim` |
| `disable` | Temporarily disable a config | `dotfiles disable tmux` |
| `list` | Show all managed configs | `dotfiles list` |

## 📁 Directory Structure

```
~/.dotfiles/
├── dotfiles           # Main management script
├── bootstrap.sh       # New machine setup
├── install.sh         # Quick command installer
├── .dotfiles-manifest # Tracking what's managed
├── CLAUDE.md          # AI assistant instructions
├── readme.md          # This file
│
├── tmux/
│   └── .tmux.conf    # → ~/.tmux.conf
├── zsh/
│   ├── .zshrc        # → ~/.zshrc
│   └── .zsh/         # → ~/.zsh (conf.d fragments)
└── nvim/             # → ~/.config/nvim
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
```bash
# Push your changes
git push

# On another machine
git pull
dotfiles deploy --dry-run  # Preview
dotfiles deploy --force     # Apply
```

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
