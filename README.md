_move this stuff to an install.sh/ps1_

# Minimum requirements

* openssh 7.3p1+ ('Include' directive)
* tmux 2.2+ (24-bit color)
** xenial instructions:
** `apt install libevent-dev ncurses-dev`
** `ghq get tmux; ghq look tmux`
** `sh autogen.sh; ./configure; sudo make install`

# Installing dotfiles

```
# wsl/xenial prep
sudo add-apt-repository ppa:git-core/ppa
    ## TODO: others
    #http://linux-packages.resilio.com/resilio-sync/debresilio-sync/non-free
    #http://ppa.launchpad.net/fish-shell/nightly-master/ubuntuxenial/main
    #http://ppa.launchpad.net/fish-shell/release-2/ubuntuxenial/main
    #http://ppa.launchpad.net/longsleep/golang-backports/ubuntuxenial/main
    #http://ppa.launchpad.net/mercurial-ppa/releases/ubuntuxenial/main
    #http://ppa.launchpad.net/neovim-ppa/stable/ubuntuxenial/main
    #https://apt.dockerproject.org/repoubuntu-xenial/main
sudo apt update

# core prereqs
apt install fish go openssh git micro nvim coreutils
## special: wsl requires pull and build/install openssh (unless can figure out how to get from xenial-backports)

# clone
cd ~
git clone git@github.com:scottbilas/dotfiles.git

# link
ln -s ~/dotfiles/config ~/.config                   # consider using $XDG_CONFIG_HOME
ln -s ~/.config/tmux/tmux.conf ~/.tmux.conf         # tmux devs refuse to support XDG; TODO: use aliasing and 'tmux -f' instead
ln -s sync:Common/Private ~/dotfiles/private

# link (windows only)
mklinkf ~/.config/git/config-windows ~/.gitconfig   # windows overrides
mklinkd ~/dotfiles/special/vscode/User $env:APPDATA/Code/User

# link (cygwin only)
ln -s ~/dotfiles/special/cygwin/profile ~/.profile

# setup ssh
mkdir .ssh
cp dotfiles/special/ssh/config .ssh/config
chmod 700 .ssh
chmod 600 .ssh/config
chmod 600 .config/ssh/config

# install ghq
go get github.com/motemen/ghq

# install fzf
ghq get junegunn/fzf
ghq look fzf
termux-fix-shebang install
install
exit

# install omf
curl -L https://get.oh-my.fish | fish
```

# Setting up tools

## VSCode

* C/C++
* C#
* Code Spell Checker
* Cram Test Language Support
* Dark+ Material
* Debugger for Unity
* EditorConfig for VS Code
* Fish shell
* Git Lens
* Guides
* LLDB Debugger
* Local History
* markdownlint
* Mono Debug
* PowerShell
* Python
* TODO Highlight
* Vim
* vscode-icons
* XML Tools
