from os import environ
from sys import stderr
from updot import ln, mkdir, platform

# import argparse, argh, see
#   https://chase-seibert.github.io/blog/2014/03/21/python-multilevel-argparse.html
# import https://github.com/dbarnett/python-selfcompletion or argcomplete

# global options:
#   what-if
#   stop-on-first

def error(text):
    stderr.write(text)


mkdir('~/bin')
mkdir('~/go/bin')

ln('~/dotfiles/config', '~/.config')
ln('~/Common/Private', '~/dotfiles/private')

mkdir('~/.ssh')
ln('~/dotfiles/private/ssh/authorized_keys', '~/.ssh/authorized_keys')

ln('~/.config/tmux/tmux.conf', '~/.tmux.conf', if_app='tmux')   # tmux refuses to support xdg (https://github.com/tmux/tmux/issues/142)
ln('~/.config/pdb/pdbrc.py', '~/.pdbrc.py')                     # pdbpp uses fancycompleter which hard codes ~/<configname> and doesn't do xdg
ln('~/.config/hyper/hyper.js', '~/.hyper.js', if_app='hyper')   # lots of XDG arguments at https://github.com/zeit/hyper/issues/137

if platform.POSIX:
    rm('~/.bash_history')
    touch('~/.hushlogin')
    ln('~/dotfiles/special/zsh/zshenv', '~/.zshenv') # http://zsh.org/mla/workers/2013/msg00692.html
    PROJ = '~/proj'

if platform.TERMUX:
    sys('termux-setup-storage')
    ln('~/.config/termux', '~/.termux')
    ln('$PREFIX', '~/usr')
    ln('~/storage/shared/Sync/Common', '~/Common')
    # ^^^ do before ssh setup

if platform.WSL:
    ln('/mnt/c', '/c')

if platform.CYGWIN:
    ln('~/dotfiles/special/cygwin/profile', '~/.profile')
    ln('~/dotfiles/special/cygwin/minttyrc', '~/.minttyrc')
    ln('/cygdrive/c', '/c')

if platform.WINDOWS:
    ln('~/.config/git/config-windows',                 '~/.gitconfig')
    ln('~/.config/omnisharp',                          '~/.omnisharp')
    ln('~/dotfiles/special/vscode/User',              f'{APPDATA}/Code/User')
    ln('~/dotfiles/private/openvpn/config',            '~/OpenVPN/config')

    ln('~/Games/Factorio',                            f'{APPDATA}/Factorio')

    ln('~/Common/_Settings/gimp-2.8',                  '.gimp-2.8')
    ln('~/Common/_Settings/Ssh',                       '.ssh')
    ln('~/Common/_Settings/minttyrc.txt',              '.minttyrc')
    ln('~/Common/Visual Studio 2017',                  'Documents/Visual Studio 2017')
    ln('~/Common/WindowsPowerShell',                   'Documents/WindowsPowerShell')

    PROJ                 = 'c:/proj'
    APPDATA              = environ["APPDATA"]
    SUBLIME_PACKAGE_ROOT = f'{APPDATA}/Sublime Text 3/Packages'

    ln('~/unity-meta/Perforce Jam Language Files',    f'{SUBLIME_PACKAGE_ROOT}/Perforce Jam Language Files')
    ln('~/unity-meta/Unity bindings',                 f'{SUBLIME_PACKAGE_ROOT}/Unity bindings')

    # env by default is the user env
    env('XDG_CONFIG_HOME', '~/.config', direxists=True)
    env('XDG_DATA_HOME', '~/.local/share')
    env('ChocolateyToolsLocation', R'~\choco')
    env(['TEMP', 'TMP'], R'c:\temp')


ln(f'{PROJ}/unity-meta', '~/unity-meta')



# registry

# vs code extensions

# nvim :PlugInstall PlugUpgrade PlugUpdate etc.

# visual studio keyboard settings

# sync scoop, choco, cyg-get, apt-get, npm, gem, pip

# parts of mc.ini and elinks configs that make sense to share

# vim
# curl -fLo ~/.local/share/nvim/site/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
# ^^ windows: make sure the ~ is expanded, or make new 'curl' command that does it
