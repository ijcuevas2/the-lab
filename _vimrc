call plug#begin('~/vimfiles/bundle')

" Make sure you use single quotes

" Any valid git URL is allowed
Plug 'https://github.com/junegunn/vim-github-dashboard.git'

" On-demand loading
" Plug 'scrooloose/nerdtree', { 'on':  'NERDTreeToggle' }
Plug 'tpope/vim-fireplace', { 'for': 'clojure' }

" Using a non-default branch
Plug 'rdnetto/YCM-Generator', { 'branch': 'stable' }

" Using a tagged release; wildcard allowed (requires git 1.9.2 or above)
Plug 'fatih/vim-go', { 'tag': '*' }

" Plugin options
Plug 'nsf/gocode', { 'tag': 'v.20150303', 'rtp': 'vim' }

Plug 'tomasr/molokai'

Plug 'sainnhe/sonokai'

Plug 'tpope/vim-commentary'

Plug 'croaker/mustang-vim'

Plug '907th/vim-auto-save'

Plug 'lervag/vimtex'

Plug 'morhetz/gruvbox'

Plug 'SirVer/ultisnips'

Plug 'Raimondi/delimitMate'

Plug 'yegappan/mru'

" Initialize plugin system
call plug#end()

" .vimrc
let g:auto_save = 1  " enable AutoSave on Vim startup

set nu
" set rnu
set tabstop=2
set shiftwidth=2
set ignorecase
set bs=2
set expandtab
set noswapfile
set background=dark
set pastetoggle=<F2>
set omnifunc=syntaxcomplete#Complete
syntax on
colorscheme gruvbox
set mouse=nicr
set guifont=Consolas:h14
set guioptions+=b

nnoremap <C-F> :promptfind <Enter>
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
"

" Enable mouse support in all modes
set mouse=a

" Map middle-click to close tab under cursor
nnoremap <silent> <expr> <MiddleMouse> TabCloseMiddleClick()

function! TabCloseMiddleClick()
    " Get the tab number under cursor
    let tabnum = tabpagenr('$')
    let curtab = tabpagenr()
    
    " Loop through tabs to find the one under the mouse cursor
    for i in range(1, tabnum)
        if getmousepos().tabnr == i
            " Switch to the tab under the cursor and close it
            execute "tabnext " . i
            execute "tabclose"
            
            " If we were on a tab after the one closed, adjust position
            if curtab > i && curtab > 1
                execute "tabnext " . (curtab - 1)
            elseif curtab == i && tabpagenr('$') >= curtab
                execute "tabnext " . curtab
            elseif curtab == i
                execute "tabnext " . tabpagenr('$')
            else
                execute "tabnext " . curtab
            endif
            
            return ''
        endif
    endfor
    
    return ''
endfunction

let loaded_matchparen=1

let g:vimtex_quickfix_mode = 2
let g:vimtex_quickfix_open_on_warning = 0
let g:vimtex_view_automatic = 0
" let g:vimtex_quickfix_autoclose_after_keystrokes = 3
"
autocmd QuickFixCmdPost * cwindow 10
 
" Disable vimtex indentation
let g:vimtex_indent_enabled = 0
let g:vimtex_indent_bib_enabled = 0

" Clear vimtex's indentexpr setting
augroup DisableVimtexIndent
    autocmd!
    autocmd FileType tex setlocal indentexpr=
    autocmd FileType tex setlocal autoindent&
    autocmd FileType tex setlocal smartindent&
    autocmd FileType tex setlocal cindent&
augroup END

" Alternative: Completely disable ALL indentation for tex files
augroup NoTexIndent
    autocmd!
    autocmd FileType tex setlocal noautoindent
    autocmd FileType tex setlocal nosmartindent
    autocmd FileType tex setlocal nocindent
    autocmd FileType tex setlocal indentexpr=
augroup END

" Enable soft wrapping
set wrap
" Make wrapped lines visually indented
set breakindent
" Show a visual indicator for wrapped lines
set showbreak=>>\ 
" Break at word boundaries rather than in the middle of words
set linebreak

" UltiSnips configuration
let g:UltiSnipsExpandTrigger="<tab>"
let g:UltiSnipsJumpForwardTrigger="<tab>"
let g:UltiSnipsJumpBackwardTrigger="<s-tab>"

" Tell UltiSnips where to look for snippets
let g:UltiSnipsSnippetDirectories=[$HOME.'/vimfiles/UltiSnips']

set noautoindent
set nocindent
set nosmartindent
set scrolloff=2

" Basic delimitMate configuration
let delimitMate_matchpairs = "(:),[:],{:}"
" Add quotes and self-matching characters (including pipe and dollar)
let delimitMate_quotes = "\" `"
let delimitMate_expand_cr = 1
let delimitMate_expand_space = 1

" Map c\ to delete rest of line and insert two backslashes
nnoremap c\ C\\<Left><Left>

" Map c\ to delete rest of line and insert two backslashes
nnoremap d> dt>

" Map leader+sv to source _vimrc
nnoremap <leader>sv :w<CR>:source $MYVIMRC<CR>:echo "File saved and Vim configuration reloaded!"<CR>

nnoremap <leader>m :MRU<CR>
inoremap <C-e> <C-x><C-e>
inoremap <C-y> <C-x><C-y>

nnoremap q <leader>le
nnoremap <leader>w :w<CR>:echo "File saved!"<CR>

set complete=.
set iskeyword-=:

if has('gui_running')
    nnoremap <C-s> :w<CR>:echo "File saved!"<CR>
    inoremap <C-s> <Esc>:w<CR>:echo "File saved!"<CR>a
    vnoremap <C-s> <Esc>:w<CR>:echo "File saved!"<CR>
endif
