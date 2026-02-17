" Disable Vi compatibility (must be first)
set nocompatible

" Enable syntax highlighting
syntax on

" Show line numbers
set number

" Use 4 spaces for tabs
set tabstop=4
set shiftwidth=4
set expandtab

" Enable mouse support (optional)
set mouse=a

" Highlight current line
set cursorline

" Better search (case-insensitive unless uppercase)
set ignorecase
set smartcase
set hlsearch

" Enable filetype detection
filetype plugin indent on

" Set leader key (default: '\', change to ',')
let mapleader = ","

" Quick save/quit shortcuts
nnoremap <leader>w :w<CR>
nnoremap <leader>q :q<CR>


" Enable wal.vim colorscheme
colorscheme wal


call plug#begin('~/.vim/plugged')
Plug 'dylanaraps/wal.vim'
call plug#end()

" Apply wal colorscheme
colorscheme wal

" Reload colorscheme if Pywal changes
autocmd BufReadPost * silent! colorscheme wal

" Make background transparent (works in some terminals)
"hi Normal guibg=NONE ctermbg=NONE


"  Default to copy from vim to clipboard
"set clipboard=unnamed
"set clipboard=unnamedplus


" Force system clipboard integration (works in Wayland/X11)
if system('uname -r | grep -i microsoft') != ''
  " WSL (Windows) - use win32yank
  set clipboard=unnamed
elseif $WAYLAND_DISPLAY != ''
  " Wayland (Hyprland) - use wl-copy/wl-paste
  set clipboard=unnamedplus
  autocmd TextYankPost * call system('wl-copy', @")
else
  " X11 - use xclip
  set clipboard=unnamedplus
  autocmd TextYankPost * call system('xclip -sel clip', @")
endif


