# Removed fbterm configuration - using kmscon instead

## Set oh-my-posh and themes
# To set your custom theme, please edit the following line and replace the default path with your custom path
PATH_OF_THE_THEME="/usr/share/oh-my-posh/themes/kushal.omp.json"

## Import easy-zsh-config
if [[ -r $HOME/.zsh/easy-zsh-config ]]; then
  source $HOME/.zsh/easy-zsh-config "${PATH_OF_THE_THEME}"
fi

## Import completion
if [[ -r $HOME/.zsh/completion ]]; then
  source $HOME/.zsh/completion
fi

## Import aliases
if [[ -r $HOME/.zsh/ssh-agent ]]; then
  source $HOME/.zsh/ssh-agent
fi

# The following lines were added by compinstall

zstyle ':completion:*' completer _expand _complete _ignored _correct _approximate
zstyle ':completion:*' list-colors ''
zstyle ':completion:*' list-prompt %SAt %p: Hit TAB for more, or the character to insert%s
zstyle ':completion:*' menu select=1
zstyle ':completion:*' select-prompt %SScrolling active: current selection at %p%s
zstyle :compinstall filename '/home/aaron/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall
# Lines configured by zsh-newuser-install
HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt beep
bindkey -e
# End of lines configured by zsh-newuser-install
export PATH="$HOME/.local/bin:$PATH"


### This is a way to provide a hint for directories containing images
##  many times we don't want to automatically use lsix to show output, but it's nice to use when we know there are files there.
# Alias the function to replace the ls command

function lsd_with_hint() {
    # Run the original lsd command
    /usr/bin/lsd "$@"

    # Check for image files in the directory
    if ls -1 "$@" | grep -E '\.(jpg|jpeg|png|gif|bmp|tiff|webp|svg)$' >/dev/null 2>&1; then
        echo "Hint: 'lsix' to see image thumbnails"
    fi
}


#alias -g ls="lsd_with_hint"
alias -g ls="/usr/bin/lsd"
alias -g cat="bat"
alias -g man="batman"
alias -g pretty="prettybat"
alias -g ip="ip -c"
alias -g whisper="whisper-client"

git config --global color.ui auto
export PATH=~/.npm-global/bin:$PATH
# Golang environment variables
# GOROOT not needed for system Go installation
# export GOROOT=/usr/local/go
export GOPATH=$HOME/go

# Update PATH to include GOPATH binaries
export PATH=$GOPATH/bin:$HOME/.local/bin:$PATH

# Added by LM Studio CLI (lms)
export PATH="$PATH:/home/aaron/.lmstudio/bin"
# End of LM Studio CLI section



