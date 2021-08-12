
" let data_dir = has('nvim') ? stdpath('data') . '/site' : '~/.vim'
" if empty(glob(data_dir . '/autoload/plug.vim'))
"   silent execute '!curl -fLo '.data_dir.'/autoload/plug.vim --create-dirs  https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
"   autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
" endif

" Specify a directory for plugins
" - For Neovim: stdpath('data') . '/plugged'
" - Avoid using standard Vim directory names like 'plugin'
call plug#begin('~/vimfiles/bundle')

" Make sure you use single quotes

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" On-demand loading
Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

Plug 'tomasr/molokai' 

Plug 'tpope/vim-commentary'

Plug '907th/vim-auto-save'

Plug 'kien/ctrlp.vim'

" Initialize plugin system
call plug#end()

" .vimrc
let g:auto_save = 1  " enable AutoSave on Vim startup

set nu
set nornu
set tabstop=2
set shiftwidth=2
set ignorecase
set bs=2
set autoindent
set expandtab
set noswapfile
" set background=dark
set pastetoggle=<F2>
set omnifunc=syntaxcomplete#Complete
"set list
syntax on
colorscheme molokai
set mouse=nicr
set guifont=Consolas:h14


" qnmap <LeftMouse> <nop>
" qimap <LeftMouse> <nop>
" qvmap <LeftMouse> <nop>
" qnmap <2-LeftMouse> <nop>
" qnmap <3-LeftMouse> <nop>

" Tmap 'ls' 
"AirlineToggleWhiteSpace
"
"NerdTree Toggle
map <C-o> :NERDTreeToggle<CR>
autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif


"autocmd BufWinLeave *.* mkview!
"autocmd BufWinEnter *.* silent loadview

if &term =~ "xterm"
     "set term=xterm-256color
     set t_Co=256
     endif

if $COLORTERM == 'gnome-terminal'
  set t_Co=2Mo56
  endif

"map <up> <nop>
"map <down> <nop>
"map <left> <nop>
"map <right> <nop>
"
"imap <up> <nop>
"imap <down> <nop>
"imap <left> <nop>
"imap <right> <nop>
"
"let g:airline#extensions#tabline#enabled = 1
set laststatus=2


"disable whitespace"
let g:airline_detect_whitespace = 0

"set guifont=Meslo\ LG\ S\ Regular\:h20

"something with tabs idk"
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'
"
let g:airline#extensions#tabline#right_sep = ' '


"let g:airline#extensions#tabline#show_tab_nr = 2

"let g:airline#extensions#tabline#tab_nr_type = 0 " # of splits (default)
let g:airline#extensions#tabline#tab_nr_type = 1 " tab number
"let g:airline#extensions#tabline#tab_nr_type = 2 " splits and tab number

let g:airline_left_sep=''
let g:airline_right_sep=''

"let g:airline_powerline_fonts = 1
"autocmd VimEnter * E
