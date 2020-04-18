  "__ _  ___ _ __   ___ _ __ __ _| |
 "/ _` |/ _ \ '_ \ / _ \ '__/ _` | |
"| (_| |  __/ | | |  __/ | | (_| | |
 "\__, |\___|_| |_|\___|_|  \__,_|_|
 "|___/
syntax on
let mapleader=","
set dir=/tmp/
set nornu
set number
set relativenumber
set nowrap
set linebreak
set splitbelow splitright
set cursorline
set backspace=indent,eol,start
set hlsearch
set pastetoggle=<F2>
set mouse=a
set incsearch
set nocompatible
"ignore case on searches
set ignorecase
"For command line autocompletion
set wildmenu
"Now the clipboard will work across environments, mac or linux
set clipboard^=unnamed,unnamedplus
" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd Filetype javascript setlocal sw=2 expandtab
" This highlights all words the cursor is under
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))

 "_ __ ___   __ _ _ __  _ __ (_)_ __   __ _ ___
"| '_ ` _ \ / _` | '_ \| '_ \| | '_ \ / _` / __|
"| | | | | | (_| | |_) | |_) | | | | | (_| \__ \
"|_| |_| |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
                "|_|   |_|            |___/

" this is to search, through out all files under the
" current directory
nnoremap <C-f> :Ack

" Clear search
nnoremap <C-e> :nohl<CR><C-l>:echo "Search Cleared"<CR>


" Shortcutting split navigation, saving a keypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" File and Window Management
nnoremap <leader>v :vsplit<CR>:w<CR>:Ex<CR>
nnoremap <leader>s :split<CR>:w<CR>:Ex<CR>

" Cycle through buffers
nmap <C-n> :bnext<CR>
nmap <C-p> :bprevious<CR>

" This is to create closing character for the following keys
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

"This is to toggle nerdtree, if it's open close it, if not go to the directory
"that your file is on
function! ToggleNerdTree()
  if exists("g:NERDTree") && g:NERDTree.IsOpen()
    :NERDTreeToggle
  else
    :NERDTreeFind
  endif
endfunction
nmap <C-q> :call ToggleNerdTree()<CR>

"To bring up the file searcher
nmap <C-g> :Files<CR>

"To bring up the buffer searcher
nmap <C-b> :Buffers<CR>


"Remove current buffer
map <leader>k :bd<CR>
"to start a markdown preview
map <leader>md :InstantMarkdownPreview<CR>

" Goyo plugin makes text more readable when writing prose:
map <leader>f :Goyo<CR>

" set the fold method
map <leader>z :set foldmethod=indent<CR>
map <leader>x :set foldmethod=manual<CR>

" open a terminal in vim, then I can copy and paste stuff as the terminal
" exists
map <leader><CR> :terminal ++curwin<CR>

"remap the vim ranger binding to r not f
let g:ranger_map_keys = 0
map <leader>r :Ranger<CR>

  "___ ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
 "/ __/ _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
"| (_| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
 "\___\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/


"Set pprint to command line variable
command PP execute "%!python -m json.tool"

"To run current line from vim to the shell
command Run execute ".w !bash"

"highlight lines that are too ling
command LL execute "/\%>80v.\+"

"copy all occureances to the a buffer, and show results
function! CopyResults(text)
    :let @a=''
    :execute "g/" . a:text . "/y A"
    :reg a
endfunction

command! -nargs=1 CopyResults call CopyResults(<f-args>)

"get the word count for a string in the current file
function! WordCount(text)
   :execute "%s/" . a:text . "//gn"
endfunction

command! -nargs=1 WordCount call WordCount(<f-args>)

 "_ __ | |_   _  __ _(_)_ __  ___
"| '_ \| | | | |/ _` | | '_ \/ __|
"| |_) | | |_| | (_| | | | | \__ \
"| .__/|_|\__,_|\__, |_|_| |_|___/
"|_|            |___/

"This is my plugin list
call plug#begin()
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'suan/vim-instant-markdown', {'for': 'markdown'}
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'vim-airline/vim-airline'
Plug 'scrooloose/nerdcommenter'
Plug 'mileszs/ack.vim'
Plug 'drewtempelmeyer/palenight.vim'
Plug 'tpope/vim-fugitive'
Plug 'vimwiki/vimwiki'
Plug 'junegunn/goyo.vim'
Plug 'francoiscabrol/ranger.vim'
Plug 'ap/vim-buftabline'
call plug#end()

 "_ __ ___ (_)___  ___
"| '_ ` _ \| / __|/ __|
"| | | | | | \__ \ (__
"|_| |_| |_|_|___/\___|

set background=dark
colorscheme palenight
let g:airline_theme = "palenight"

filetype plugin on

" vimwiki with markdown support
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
" helppage -> :h vimwiki-syntax

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" vim-instant-markdown - Instant Markdown previews from Vim
" https://github.com/suan/vim-instant-markdown
let g:instant_markdown_autostart = 0	" disable autostart

" Save file as sudo on files that require root permission
cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Return to the same line you left off at
augroup line_return
	au!
	au BufReadPost *
		\ if line("'\"") > 0 && line("'\"") <= line("$") |
		\	execute 'normal! g`"zvzz' |
		\ endif
augroup END

so ~/dotfiles/vim/coc.vim
