# Set oh-my-posh theme — override PATH_OF_THE_THEME in ~/.zshrc.local
PATH_OF_THE_THEME="/usr/share/oh-my-posh/themes/kushal.omp.json"

# Load machine-local config early so it can override theme and key settings
[[ -r "$HOME/.zshrc.local" ]] && source "$HOME/.zshrc.local"

## Core shell config: history, completion, keybindings, plugins, prompt
[[ -r "$HOME/.zsh/easy-zsh-config" ]] && source "$HOME/.zsh/easy-zsh-config" "${PATH_OF_THE_THEME}"

## Completion overrides
[[ -r "$HOME/.zsh/completion" ]] && source "$HOME/.zsh/completion"

## SSH agent
[[ -r "$HOME/.zsh/ssh-agent" ]] && source "$HOME/.zsh/ssh-agent"

## Aliases
[[ -r "$HOME/.zsh/aliases" ]] && source "$HOME/.zsh/aliases"

## PATH
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

## Go
export GOPATH="$HOME/go"
export PATH="$GOPATH/bin:$PATH"

## Misc
git config --global color.ui auto

## direnv
command -v direnv &>/dev/null && eval "$(direnv hook zsh)"
