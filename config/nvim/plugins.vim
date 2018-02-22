Plug 'easymotion/vim-easymotion'
Plug 'editorconfig/editorconfig-vim'
Plug 'fholgado/minibufexpl.vim'
Plug 'flazz/vim-colorschemes'
Plug 'mbbill/undotree'
Plug 'mhinz/vim-startify'
Plug 'ntpeters/vim-better-whitespace'
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'terryma/vim-multiple-cursors'
Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
Plug 'tmhedberg/SimpylFold'
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'Xuyuanp/nerdtree-git-plugin'

if has("unix")
    Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
    Plug 'junegunn/fzf.vim'
endif

" Must be after nerdtree related plugins above
Plug 'ryanoasis/vim-devicons'

let g:startify_bookmarks = [
    \ { 'c': '~/.config/nvim/init.vim' }
    \ ]

let g:startify_relative_path=1
let g:startify_update_oldfiles=1
let g:startify_session_autoload=1
let g:startify_session_persistence=1

let g:NERDTreeMinimalUI=1
let g:NERDTreeDirArrows=1
let g:NERDTreeQuitOnOpen=1
let g:NERDTreeAutoDeleteBuffer=1

let g:undotree_ShortIndicators=1

