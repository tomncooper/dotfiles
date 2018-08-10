" Vim Config - Tom Cooper 

" Cancel the compatibility with Vi. Essential if you want
" to enjoy the features of Vim
set nocompatible
set encoding=utf-8

"Temp shut off filetype for vundle setup
filetype off

" set the runtime path to include Vundle and initialize
set rtp+=$HOME/.vim/bundle/Vundle.vim

"Start vundle config
call vundle#begin()

" let Vundle manage Vundle, required
Plugin 'VundleVim/Vundle.vim'

"Add custom plugins here
Plugin 'vim-airline/vim-airline'
Plugin 'w0rp/ale'
Plugin 'tpope/vim-fugitive'
Plugin 'airblade/vim-gitgutter'
Plugin 'scrooloose/nerdtree'
Plugin 'Xuyuanp/nerdtree-git-plugin'
Plugin 'vimwiki/vimwiki'
Plugin 'mattn/calendar-vim'
Plugin 'Valloric/YouCompleteMe'
Plugin 'vim-pandoc/vim-pandoc'
Plugin 'vim-pandoc/vim-pandoc-syntax' 

"End the vundle config
call vundle#end() 

" -- Display
set title                 " Update the title of your window or your terminal
set relativenumber	  " Sets all line numbers to be displayed relative to the current line
set number                " Display line numbers
set ruler                 " Display cursor position
set wrap                  " Wrap lines when they are too long

set scrolloff=3           " Display at least 3 lines around you cursor
                          " (for scrolling)

set guioptions=T          " Enable the toolbar
set colorcolumn=90        " Set the end on line indicator strip
set tw=90                 " Set the text width so that hard wrapping occurs

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
imap ii <Esc>

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

" YouCompleteMeSettings
" Set the python binary path so that it will use the virtualenv python 
let g:ycm_python_binary_path = 'python'
" Set a shortcut for GoTo commands
nnoremap <leader>jd :YcmCompleter GoTo<CR>

" VimWiki options
let g:vimwiki_list = [{
    \ 'path': '$HOME/GDrive/Documents/Wikis/phd', 
    \ 'path_html': '$HOME/GDrive/Documents/Wikis/phd/html',
    \ 'template_path' : '$HOME/GDrive/Documents/Wikis/templates',
    \ 'template_default' : 'default',
    \ 'template_ext' : '.html'}]
let g:vimwiki_use_calendar = 1

" Vim-PanDoc options
let g:pandoc#modules#disabled = ["folding"]

" ALE options
let g:ale_python_mypy_options = "-s"


" NERD Tree settings
" Auto Open 
"autocmd VimEnter * NERDTree
"autocmd BufWinEnter * NERDTreeMirror
