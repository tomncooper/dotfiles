" Vim Config - Tom Cooper 

" Cancel the compatibility with Vi. Essential if you want
" to enjoy the features of Vim
set nocompatible
set encoding=utf-8

" Set ALE to provide completion - This has to be set before ALE loads
let g:ale_completion_enabled = 1

" Load vim plug if it is not already there
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

" Run PlugInstall if there are missing plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

"Start vim plug config
call plug#begin('~/.vim/plugged')

"Add custom plugins here
Plug 'vim-airline/vim-airline'
Plug 'w0rp/ale'
Plug 'psf/black'
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'
Plug 'scrooloose/nerdcommenter'
Plug 'fatih/vim-go'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax' 
Plug 'preservim/nerdtree'
Plug 'neoclide/coc.nvim', {'branch': 'release'}

"End the vim plug config
call plug#end() 

" -- Display
set title                 " Update the title of your window or your terminal
set relativenumber	  " Sets all line numbers to be displayed relative to the current line
set number                " Display line numbers
set ruler                 " Display cursor position
set wrap                  " Wrap lines when they are too long
set linebreak
set nolist

set scrolloff=6           " Display at least 6 lines around you cursor (for scrolling)

set guioptions=T          " Enable the toolbar
set textwidth=90          " Set the text width so that hard wrapping occurs
set colorcolumn=90        " Set the end on line indicator strip

"Set the tab key to provide a 4 space indent - Spaces not tabs FTW!
set tabstop=8 softtabstop=0 expandtab shiftwidth=4 smarttab

" Make the backspace key do normal things
set backspace=2

" Auto-close the preview window after a completion suggestion has been selected
autocmd CompleteDone * pclose

" Stop vim switching directory to match the first file opened
set noautochdir

" -- Search
set ignorecase            " Ignore case when searching
set smartcase             " If there is an uppercase in your search term
                          " search case sensitive again
set incsearch             " Highlight search results when typing
set hlsearch              " Highlight search results

" -- Beep
set visualbell            " Prevent Vim from  beeping
set noerrorbells          " Prevent Vim from  beeping

" Hide buffer (file) instead of abandoning when switching to another buffer
set hidden

"Enable syntax highlighting
let python_highlight_all=1
syntax enable

"Enable file specific behaviour like syntax highlighting and indention
filetype on 
filetype plugin on 
filetype indent on

"Use the dark version of the solarized theme
set background=dark
colorscheme solarized

" Set the Spell Check highlighting options
set spell spelllang=en_gb
hi clear SpellBad
hi SpellBad cterm=underline ctermfg=white ctermbg=red

"Disable the directional keys so you can be like a real hacker
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

"Remap the escape key to be 2 presses of the i key so it is easier to reach
"imap ii <Esc>

"Remap the leader key to be the space bar
let mapleader = "\<Space>"

"Remap the window nav keys to make split navigation easier
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

"Add in a command that will clear the last search so that old search terms
"are not highlighted
command! C let @/=""

"Add an auto command to remove trailing white space from python files after 
"every save
autocmd BufWritePre *.py %s/\s\+$//e

" Activate the enhanced file finder menu
set wildmenu
" Tell wildmenu to not offer to open certain files (that shouldn't be opened in
" a text editor)
set wildignore+=*.bmp,*.gif,*.ico,*.jpg,*.png,*.ico
set wildignore+=*.pdf,*.psd
set wildignore+=*.pyc

""""" Plugin Settings """"

" Airline settings
set laststatus=2 " Enable airline status bar without needing to split the window
let g:airline_powerline_fonts = 1
let g:airline#extensions#tabline#enabled = 1

" coc.nvim settings 

" use <tab> for trigger completion and navigate to the next complete item
function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~ '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ pumvisible() ? "\<C-n>" :
      \ <SID>check_back_space() ? "\<Tab>" :
      \ coc#refresh()

" Black settings
"autocmd BufWritePre *.py execute ':Black'

" Vim-PanDoc options
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#formatting#mode = 'sA'
let g:pandoc#formatting#textwidth = 90
if !exists('g:ycm_semantic_triggers')
    let g:ycm_semantic_triggers = {}
  endif
  let g:ycm_semantic_triggers.pandoc = ['@']

  let g:ycm_filetype_blacklist = {}

" ALE options
let g:ale_python_mypy_options = "--ignore-missing-imports"

" NERDTree options
map <C-n> :NERDTreeToggle<CR>
