  "__ _  ___ _ __   ___ _ __ __ _| |
 "/ _` |/ _ \ '_ \ / _ \ '__/ _` | |
"| (_| |  __/ | | |  __/ | | (_| | |
 "\__, |\___|_| |_|\___|_|  \__,_|_|
 "|___/
syntax on
let mapleader=","
set dir=/tmp/
set wrap
set nornu
set number
set relativenumber
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
set clipboard=unnamedplus
" Automatically deletes all trailing whitespace on save.
autocmd BufWritePre * %s/\s\+$//e
autocmd Filetype javascript setlocal sw=2 expandtab
" This highlights all words the cursor is under
autocmd CursorMoved * exe printf('match IncSearch /\V\<%s\>/', escape(expand('<cword>'), '/\'))
" So I can view unicode characters
set encoding=utf-8

 "_ __ ___   __ _ _ __  _ __ (_)_ __   __ _ ___
"| '_ ` _ \ / _` | '_ \| '_ \| | '_ \ / _` / __|
"| | | | | | (_| | |_) | |_) | | | | | (_| \__ \
"|_| |_| |_|\__,_| .__/| .__/|_|_| |_|\__, |___/
                "|_|   |_|            |___/


" Shortcutting split navigation, saving a eypress:
map <C-h> <C-w>h
map <C-j> <C-w>j
map <C-k> <C-w>k
map <C-l> <C-w>l

" Clear search
nnoremap <C-e> :nohl<CR><C-l>:echo "Search Cleared"<CR>

" this is to search, through out all files under the
" current directory
nnoremap <C-f> :Ack


" Cycle through buffers
nmap <C-o> :bprevious<CR>
nmap <C-p> :bnext<CR>

" This is to create closing character for the following keys
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" Relative or absolute number lines
function! NumberToggle()
    if(&number == 1)
        set number!
        set relativenumber!
      elseif(&relativenumber==1)
        set relativenumber
        set number
      else
        set norelativenumber
        set number
    endif
endfunction

nnoremap <C-n> :call NumberToggle()<CR>

function! TerminalPasteTool()
  :silent %s/\n -d/ -d
  :silent .  w !bash | python -m json.tool | xsel --clipboard
  :vnew
  normal! "+p
endfunction


nnoremap <C-t> :call TerminalPasteTool()<cr>

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

nmap <C-s> :setlocal spell! spelllang=en_us<CR>

" _                _
"| | ___  __ _  __| | ___ _ __
"| |/ _ \/ _` |/ _` |/ _ \ '__|
"| |  __/ (_| | (_| |  __/ |
"|_|\___|\__,_|\__,_|\___|_|


" File and Window Management
nnoremap <leader>v :vsplit<CR>:w<CR>:Ex<CR>
nnoremap <leader>s :split<CR>:w<CR>:Ex<CR>

"Remove current buffer
map <leader>k :bd!<CR>
"to start a markdown preview
map <leader>md :InstantMarkdownPreview<CR>
"Stop auto previewing markdown pages
let g:instant_markdown_autostart = 0

" Goyo plugin makes text more readable when writing prose:
map <leader>f :set wrap <bar> :Goyo<CR>

" set the fold method
map <leader>z :set foldmethod=indent<CR>
map <leader>x :set foldmethod=manual<CR>

" open a terminal in vim, then I can copy and paste stuff in the terminal
map <leader><CR> :terminal ++noclose ++curwin<CR>

"remap the vim ranger binding to r not f
let g:ranger_map_keys = 0
map <leader>r :Ranger<CR>

"run visual select as a shell command
map <leader>e :'<,'>terminal bash<CR>

"Pretty Print a selection
map <leader>p :'<,'>!python -m json.tool<CR>

"Python Formatting
autocmd FileType python set sw=4
autocmd FileType python set ts=4
autocmd FileType python set sts=4
autocmd FileType python setlocal colorcolumn=79

  "___ ___  _ __ ___  _ __ ___   __ _ _ __   __| |___
 "/ __/ _ \| '_ ` _ \| '_ ` _ \ / _` | '_ \ / _` / __|
"| (_| (_) | | | | | | | | | | | (_| | | | | (_| \__ \
 "\___\___/|_| |_| |_|_| |_| |_|\__,_|_| |_|\__,_|___/


"Set pprint to command line variable
command PP execute "%!python -m json.tool"

"To run current line from vim to the shell
command Run execute ".w !bash"

"highlight lines that are too long
command LL execute "/\%>80v.\+"

"Sudo write when I forgot to open in sudo
command SudoWrite execute "w !sudo tee %"

"copy all occureances to the a buffer, and show results
function! CopyResults(text)
    :let @a=''
    :execute "g/" . a:text . "/y A"
    :reg a
endfunction

command! -nargs=1 CopyResults call CopyResults(<f-args>)

"copy all occureances and past into a vsplit
function! CopyResultsSplit(text)
    "figure out how to update vim to check for the buffer
    ":bdelete \'scratchpad.txt\'
    :let @a=''
    :execute "g/" . a:text . "/y A"
    :vsplit
    :edit scratchpad.txt
    :normal "aP
endfunction

command! -nargs=1 CopyResultsSplit call CopyResultsSplit(<f-args>)

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
Plug 'dbeniamine/cheat.sh-vim'
Plug 'josa42/coc-sh'
Plug 'honza/vim-snippets'
Plug 'sheerun/vim-polyglot'
Plug 'airblade/vim-gitgutter'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'instant-markdown/vim-instant-markdown', {'for': 'markdown'}
Plug 'scrooloose/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
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
Plug 'rigellute/shades-of-purple.vim'
Plug 'lervag/vimtex'
call plug#end()

 "_ __ ___ (_)___  ___
"| '_ ` _ \| / __|/ __|
"| | | | | | \__ \ (__
"|_| |_| |_|_|___/\___|

set background=dark
colorscheme shades_of_purple
let g:shades_of_purple_lightline = 1
let g:lightline = { 'colorscheme': 'shades_of_purple' }

let g:tex_flavor = 'latex'
let g:vimtex_view_use_temp_files='zathura'
let g:vimtex_view_method = 'zathura'
filetype plugin on


hi SpellBad guibg=#ff2929 ctermbg=224

"no mappings for cheat just use HowIn as a command much easier
let g:CheatSheetDoNotMap=1

" vimwiki with markdown support
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
" helppage -> :h vimwiki-syntax

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]


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

