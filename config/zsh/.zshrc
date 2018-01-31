# this will process .zpreztorc and load all modules
if [[ -s "${ZDOTDIR:-$HOME}/.zprezto/init.zsh" ]]; then
  source "${ZDOTDIR:-$HOME}/.zprezto/init.zsh"
fi

# override history module settings
HISTFILE="$HOME/.local/share/zsh/history"
setopt NO_SHARE_HISTORY # keep history unique between sessions

source ~/.config/zsh/aliases
