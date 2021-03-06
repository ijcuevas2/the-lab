set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
" git clone https://github.com/VundleVim/Vundle.vim.git %USERPROFILE%/.vim/bundle/Vundle.vim
if has("win32")
    set rtp+=~/vimfiles/bundle/Vundle.vim/
    let vundlepath='~/vimfiles/bundle'
else
    set rtp+=~/.vim/bundle/Vundle.vim
    let vundlepath='~/.vim/bundle'
endif

call vundle#begin(vundlepath)
" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')
Plugin 'VundleVim/Vundle.vim'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" Git plugin not hosted on GitHub
" Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}

"monokai"
Plugin 'tomasr/molokai'

"Tab Number"
"Plugin 'mkitt/tabline.vim'

"Conque-Shell"
" Plugin 'vim-scripts/Conque-Shell'

"bling airline"
Plugin 'bling/vim-airline'

"vim proc"
Plugin 'Shougo/vimproc.vim'

"VimShell"
Plugin 'Shougo/vimshell.vim'

"Those Special Fonts"
" Plugin 'powerline/fonts'

"Spotify"
Bundle 'takac/vim-spotifysearch'

" All of your Plugins must be added before the following line
Bundle 'morhetz/gruvbox'

Plugin 'chriskempson/base16'
"Base 16 colors
Plugin 'chriskempson/base16-vim'

"Good Light Theme"
Plugin 'jonathanfilip/vim-lucius'
" call vundle#config#require(g:bundles)

"Save Folds
Plugin 'vim-scripts/restore_view.vim' 

"Mustang
Plugin 'croaker/mustang-vim'

"tcomment
Plugin 'tomtom/tcomment_vim'

" delimiters
Plugin 'Raimondi/delimitMate'

"Typescript
Plugin 'leafgarland/typescript-vim'

" Swift
Plugin 'keith/swift.vim'

" Nerdtree
Plugin 'scrooloose/nerdtree'

"nvim
Plugin 'kassio/neoterm'

"Python
Plugin 'hdima/python-syntax'

" javascript
Plugin 'jelera/vim-javascript-syntax'

" Splits
Plugin 'christoomey/vim-tmux-navigator'

call vundle#end()            " required
filetype plugin on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

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
colorscheme mustang
set mouse=nicr

nmap <LeftMouse> <nop>
imap <LeftMouse> <nop>
vmap <LeftMouse> <nop>
nmap <2-LeftMouse> <nop>
nmap <3-LeftMouse> <nop>

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
