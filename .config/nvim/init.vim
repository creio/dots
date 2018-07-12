call plug#begin('~/.local/share/nvim/plugged')

Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'jiangmiao/auto-pairs' 
Plug 'kien/ctrlp.vim'
Plug 'easymotion/vim-easymotion'
Plug 'itchyny/lightline.vim'
Plug 'Yggdroot/indentLine'
" color theme
Plug 'arcticicestudio/nord-vim'
Plug 'morhetz/gruvbox'
Plug 'rking/ag.vim'

call plug#end()

autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif 

syntax on
let g:mapleader=','
let NERDTreeShowHidden=1

"" Visual Setting
set background=dark
colorscheme nord
"colorscheme gruvbox

set number
set mouse=a

"" Bell
set noerrorbells
set visualbell

"" Encoding
set ttyfast
set binary

"" Searching
set nohlsearch
set incsearch
set ignorecase
set smartcase

"" Tabs, May be overwritten by autocmd rules
set shiftwidth=2
set softtabstop=0
set tabstop=2
set expandtab

"" Code Folding
set foldenable
set foldmethod=manual

"" NERDTree Configuration
let NERDTreeChDirMode = 2
let NERDTreeIgnore=['\.rbc$', '\~$', '\.pyc$', '\.sqlite$', '__pycache__']
let NERDTreeSortOrder=['^__\.py$', '\/$', '*', '\.swp$','\.bak$', '\~$']
"let NERDTreeShowBookmarks = 1
"let NERDTree_tabs_focus_on_files=1
let NERDTreeMapOpenInTabSilent = '<RightMouse>'
let NERDTreeDirArrows = 1
set wildignore+=*/tmp/*,*.so,*.swp,*.zip,*.pyc,*.db,*.sqlite
nnoremap <silent> <F2> :NERDTreeFind<CR>
map <C-n> :NERDTreeToggle<CR>

map <Leader> <Plug>(easymotion-prefix)

vmap cc :norm i#<CR>
vmap uc :norm ^x<CR>

" Lightline.vim
" http://git.io/lightline
set laststatus=2
let g:lightline = {
  \ 'colorscheme': 'wombat',
  \ 'separator': { 'left': '', 'right': '' },
  \ }