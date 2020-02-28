" General Vim settings
	syntax on
	let mapleader=","
	"set autoindent
	"set tabstop=4
	"set shiftwidth=4
	set dir=/tmp/
	set nornu
	set number
	set relativenumber
        set nowrap
	set linebreak
	"autocmd Filetype html setlocal sw=2 expandtab
	autocmd Filetype javascript setlocal sw=2 expandtab

	set cursorline

	set hlsearch
	nnoremap <C-F> :nohl<CR><C-l>:echo "Search Cleared"<CR>
	nnoremap <C-c> :set norelativenumber<CR>:set nonumber<CR>:echo "Line numbers turned off."<CR>
	nnoremap <C-r> :set relativenumber<CR>:set number<CR>:echo "Line numbers turned on."<CR>

	set backspace=indent,eol,start

	nnoremap <leader><tab> :set list!<cr>
	set pastetoggle=<F2>
	set mouse=a
	set incsearch


" File and Window Management
	nnoremap <leader>v :vsplit<CR>:w<CR>:Ex<CR>
	nnoremap <leader>s :split<CR>:w<CR>:Ex<CR>

" Return to the same line you left off at
	augroup line_return
		au!
		au BufReadPost *
			\ if line("'\"") > 0 && line("'\"") <= line("$") |
			\	execute 'normal! g`"zvzz' |
			\ endif
	augroup END


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
Plug 'joshdick/onedark.vim'
Plug 'tpope/vim-fugitive'
Plug 'vimwiki/vimwiki'
Plug 'junegunn/goyo.vim'
call plug#end()

set nocompatible
filetype plugin on


" Shortcutting split navigation, saving a keypress:
	map <C-h> <C-w>h
	map <C-j> <C-w>j
	map <C-k> <C-w>k
	map <C-l> <C-w>l


"This is to create closing character for the following keys
inoremap " ""<left>
inoremap ' ''<left>
inoremap ( ()<left>
inoremap [ []<left>
inoremap { {}<left>
inoremap {<CR> {<CR>}<ESC>O
inoremap {;<CR> {<CR>};<ESC>O

" vimwiki with markdown support
let g:vimwiki_ext2syntax = {'.md': 'markdown', '.markdown': 'markdown', '.mdown': 'markdown'}
" helppage -> :h vimwiki-syntax

let g:vimwiki_list = [{'path': '~/vimwiki/',
                      \ 'syntax': 'markdown', 'ext': '.md'}]

" vim-instant-markdown - Instant Markdown previews from Vim
" https://github.com/suan/vim-instant-markdown
let g:instant_markdown_autostart = 0	" disable autostart
map <leader>md :InstantMarkdownPreview<CR>

" so I can add the python idpb trace with one keystroke
nnoremap <leader>p oimport ipdb; ipdb.set_trace()<Esc>

" Automatically deletes all trailing whitespace on save.
	autocmd BufWritePre * %s/\s\+$//e

" Save file as sudo on files that require root permission
	cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

" Goyo plugin makes text more readable when writing prose:
	map <leader>f :Goyo<CR>

"Color Scheme
let g:onedark_termcolors=256
colorscheme onedark

"For command line autocompletion
set wildmenu


"Now the clipboard will work across environments, mac or linux
set clipboard^=unnamed,unnamedplus

"Set pprint to command line variable
command PP execute "%!python -m json.tool"

"To run current line from vim to the shell
command Run execute ".w !bash"

"ignore case on searches
set ignorecase

"highlight lines that are too ling
command LL execute "/\%>80v.\+"

"This is to be able to delete
nnoremap d "_d
vnoremap d "_d

"This is toggle nerdtree
nmap <C-n> :NERDTreeToggle<CR>

"To bring up the file searcher
nmap <C-g> :Files<CR>

"To bring up the buffer searcher
nmap <C-b> :Buffers<CR>

nmap <C-H> :bnext<CR>
nmap <C-L> :bprevious<CR>
