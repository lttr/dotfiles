"          _
"  __   __(_) _ __ ___   _ __  ___
"  \ \ / /| || '_ ` _ \ | '__|/ __|
"   \ V / | || | | | | || |  | (__
"    \_/  |_||_| |_| |_||_|   \___|
"

"  This vimrc {{{ ==============================================================

"@ Lukas Trumm, since 2014

" Source the vimrc file after saving it
augroup configuration
  autocmd!
  autocmd BufWritePost .vimrc,_vimrc,vimrc source $MYVIMRC
augroup END


" }}}
"  Plugins {{{ =================================================================

call plug#begin()

" Code generation
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'garbas/vim-snipmate'
Plug 'tomtom/tlib_vim'
Plug 'honza/vim-snippets'
Plug 'lttr/sql_iabbr.vim'
Plug 'vim-scripts/loremipsum'
Plug 'vim-scripts/SyntaxComplete'

" Code style
Plug 'Chiel92/vim-autoformat'
Plug 'scrooloose/syntastic'
Plug 'editorconfig/editorconfig-vim'
Plug 'maksimr/vim-jsbeautify'

" Documentation
Plug 'KabbAmine/zeavim.vim'
Plug 'chrisbra/unicode.vim'

" Editing
Plug 'maxbrunsfeld/vim-yankstack'
Plug 'PeterRincker/vim-argumentative'
Plug 'AndrewRadev/splitjoin.vim'
Plug 'Raimondi/delimitMate'
Plug 'drmikehenry/vim-fontsize'
Plug 'godlygeek/tabular'
Plug 'coderifous/textobj-word-column.vim'
Plug '907th/vim-auto-save'
Plug 'michaeljsmith/vim-indent-object'
Plug 'vim-scripts/Yankitute'
Plug 'tommcdo/vim-exchange'
Plug 'tpope/vim-abolish'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-commentary'
Plug 'salsifis/vim-transpose'
Plug 'scrooloose/nerdcommenter'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'vim-scripts/visSum.vim'
Plug 'vim-scripts/matchit.zip'
Plug 'terryma/vim-multiple-cursors' , { 'on': 'MultipleCursorsFind' }
Plug 'triglav/vim-visual-increment'
Plug 'tpope/vim-unimpaired'
Plug 'osyo-manga/vim-over'

" Files
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-rooter'
" Plug 'rking/ag.vim'
Plug 'vim-scripts/Rename'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'majutsushi/tagbar' , { 'on': 'TagbarToggle' }
Plug 'mbbill/undotree' , { 'on': 'UndotreeToggle' }
Plug 'tpope/vim-eunuch'
Plug 'airblade/vim-rooter'
Plug 'wting/gitsessions.vim'

" Html, xml, css
Plug 'othree/xml.vim'
Plug 'othree/html5.vim'
Plug 'Valloric/MatchTagAlways' , has('python') ? {} : { 'on' : [] }
Plug 'mattn/emmet-vim'
Plug 'jvanja/vim-bootstrap4-snippets'
Plug 'hail2u/vim-css3-syntax'
Plug 'groenewege/vim-less' , { 'for': 'less' }
Plug 'chrisbra/Colorizer'

" Javascript
Plug 'pangloss/vim-javascript'
Plug 'ternjs/tern_for_vim' , has('unix') ? {} : { 'on' : [] }
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'arturbalabanov/vim-angular-template'
Plug 'Quramy/vim-js-pretty-template'
Plug 'elzr/vim-json'
Plug 'webdesus/polymer-ide.vim', { 'do': 'npm install' }

" Typescript
Plug 'Quramy/tsuquyomi'
Plug 'Quramy/vim-js-pretty-template'
Plug 'leafgarland/typescript-vim'
Plug 'magarcia/vim-angular2-snippets'
Plug 'bdauria/angular-cli.vim'

" PHP
Plug 'shawncplus/phpcomplete.vim' , { 'for': 'php' }
Plug 'StanAngeloff/php.vim' , { 'for': 'php' }
Plug 'vim-scripts/Nette' , { 'for': 'php' }

" Python
Plug 'klen/python-mode' , { 'for': 'python' }

" Tools
Plug 'metakirby5/codi.vim'
Plug 'janko-m/vim-test'
Plug 'vim-scripts/Shebang'
Plug 'fboender/bexec'
Plug 'glts/vim-magnum'
Plug 'glts/vim-radical'
Plug 'kannokanno/previm'
Plug 'qpkorr/vim-renamer'
Plug 'junegunn/fzf', { 'dir': '~/.fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'

" Special file types
Plug 'chrisbra/csv.vim', { 'for': 'csvx' }
Plug 'dzeban/vim-log-syntax' , { 'for': 'log' }
Plug 'andreshazard/vim-freemarker' , { 'for': 'freemarker' }
Plug 'vobornik/vim-mql4' , { 'for': 'mql4' }
Plug 'vim-scripts/dbext.vim' , { 'for': 'sql' }
Plug 'vim-scripts/gnuplot.vim' , { 'for': 'gnuplot' }
Plug 'gabrielelana/vim-markdown' , { 'for': 'markdown' }
Plug 'blockloop/vim-swigjs', { 'for': 'html' }
Plug 'stephpy/vim-yaml', { 'for': 'yaml' }

" Version control
Plug 'gregsexton/gitv' , { 'on': 'Gitv' }
Plug 'tpope/vim-fugitive'
Plug 'airblade/vim-gitgutter'

" Window management
Plug 'milkypostman/vim-togglelist'
Plug 'junegunn/goyo.vim'
Plug 'Shougo/vimproc.vim'
Plug 'vim-voom/VOoM'
Plug 'moll/vim-bbye'
Plug 'sjl/clam.vim'
Plug 'tyru/open-browser.vim'
Plug 'tyru/restart.vim'
Plug 'tpope/vim-dispatch'

call plug#end()

" }}}
"  General settings {{{ ========================================================

set confirm                    " Less errors, more questions
set backspace=indent,eol,start " Allow backspase in insert mode
set autoread                   " Relaod files changed outside Vim
set nrformats  =alpha          " Think about all formats as decimal
set history    =500            " Keep 200 items in history of Ex commands
" Message abbreviations, truncate file messages, dont warn if existing swap files,
" hide the welcome screen, truncate other long messages
set shortmess  =atAIT
set nostartofline              " Don't jump to first character when paging
set number                     " Line numbers before lines
set iskeyword+=-               " Count strings joined by dashes as words
set noshelltemp                " Should avoid some cmd windows for external commands
set modeline                   " Make sure modelines are read

" ===== Buffers =====
set hidden                     " Allow buffer switching without saving
set splitright                 " Puts new vsplit windows to the right of the current
set splitbelow                 " Puts new split windows to the bottom of the current
set diffopt+=vertical          " Use vertical layout when using vim as mergetool

" ===== Directories ======
set backup                     " Make backups
if has('unix')
  set backupdir  =~/.vim/backups     " List of directory names for backup files
  set directory  =~/.vim/backups     " List of directory names for swap files
  set undodir    =~/.vim/undos       " List of directory names for undo files
else
  set backupdir  =~/vimfiles/backups " List of directory names for backup files
  set directory  =~/vimfiles/backups " List of directory names for swap files
  set undodir    =~/vimfiles/undos   " List of directory names for undo files
endif
set undofile                   " Automatically saves undo history to an undo file
set undolevels =1000           " Maximum number of changes that can be undone
set undoreload =10000          " Maximum number lines to save for undo on a buffer reload
set writebackup                " Make a backup before overwriting a file
set tags       =./.tags;       " Find tags file in parent dirs (;) starting in current dir (./)

" ===== Folding =====
set foldmethod =marker

" ===== Language and encoding =====
set encoding   =utf-8

" ===== Lines =====
set linespace     =1           " Vertical space between lines (in pixels, 1 = default on win)
set scrolloff     =1           " Let one line above and bellow
set sidescroll=1
set sidescrolloff=15
set nojoinspaces               " Prevents inserting two spaces after punctuation on a join (J)
set display       =lastline    " Display as much as possible from the last (wrapped) line on the screen
set formatoptions -=o          " Do not generally insert comment leader after 'o'
set formatoptions +=j          " Remove comment leader when joining lines
set formatoptions +=l          " Long lines remains long in insert mode
set formatoptions +=n          " Recognize numbered lists
set formatoptions +=r          " Automatically insert comment leader after Enter
set formatoptions +=w          " Trailing white space indicates a paragraph continues
set formatoptions +=1          " Don't break line after one-letter word

" ===== Search =====
set incsearch                  " Highlight during typing (=incremental searching)
set ignorecase                 " Search case-insensitive
set smartcase                  " ...except upper-case included
set wildmenu                   " Show list instead of just completing

" ===== Tabs and indentation =====
set tabstop     =4             " Number of spaces that <Tab> counts for
set softtabstop =4             " Tabs and Backspaces feels like <Tab>
set shiftwidth  =4             " Number of spaces to use for each step of indent
set shiftround                 " Round the size of indentation (using < and >) to shiftwidth
set virtualedit =""            " Do not move the cursor behind last char
" Following are not needed after vim-sleuth plugin is installed
set autoindent                 " Copy indent from current line when starting a new line
set copyindent                 " Autoindent the new line
set smarttab                   " Inserts or deletes blanks according to tab settings
set cindent                    " Apply indentation rules for c-like languages
set expandtab                  " Force spaces over tabs, also with :retab

" ===== Wrapping =====
set textwidth =0               " Maximum width of text that is being inserted (0 = no hard wrap)
set linebreak                  " Dont wrap words
if exists('&breakindent')
  set breakindent            " Soft wrapped lines will continue visually indented (since vim 7.4.x)
endif

" ===== Mouse =====
set mouse=a                    " Enable the use of mouse in terminal


" Leave the insert mode without waiting for another hotkey,
" because <Esc> is used to simulate <Alt> in some terminals.
if ! has('gui_running')
  set ttimeoutlen=10
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0
    au InsertLeave * set timeoutlen=1000
  augroup END
endif


" }}}
"  Appearance {{{ ==============================================================

"  ===== Language =====
if has('unix')
  language en_US.UTF-8
else
  language us
endif

" ===== Cursor =====
set guicursor+=a:blinkon0   " Disable blinking cursor in normal mode

" Change cursor shape in different modes in terminal
if has('unix')
  let &t_SI = "\<Esc>[6 q"
  let &t_SR = "\<Esc>[4 q"
  let &t_EI = "\<Esc>[2 q"
endif

" ===== Font =====
if has('unix')
  " Font for vim-devicons
  set guifont=DejaVuSansMonoForPowerline\ Nerd\ Font\ 12
else
  " Best Windows font
  set guifont=Consolas:h12
endif

" ===== GUI adjustments =====
set guioptions-=b  " Hide horizontal (bottom) scrollbar
set guioptions-=e  " Text based tabs
set guioptions-=l  " Hide left vertical scrollbar
set guioptions-=L  " Hide left scrollbar even when there is vertical split window
set guioptions-=m  " Remove menu bar
set guioptions-=R  " Hide right scrollbar even when there is vertical split window
set guioptions-=T  " Remove toolbar
set guitablabel=%f " File name in tab

" Toggle horizontal scrollbar
" <coW> corresponds to <cow> for toggle wrap
nnoremap <silent> coW :call ToggleFlag('guioptions', 'b')<CR>

" ===== Status line  =====
set noruler                                 " No useful info in ruler for me
set laststatus =2                           " Always show statusline
" Left side
set statusline =                            " Reset of the statusline
set statusline +=\ %<%f                     " Tail of the filename
set statusline +=\ %m                       " Modified flag
set statusline +=\ %r                       " Read only flag
" Insert current git branch name, 7 chars from commit in case of detached HEAD
set statusline +=\ %{exists('g:loaded_fugitive')?fugitive#head(7):''}
" Separator
set statusline +=\ %=                       " Left/right separator
" Right side
set statusline +=\ \|\ %{&ft}               " Filetype (neither %y nor %Y does fit)
set statusline +=\ \|\ %{&fenc}             " File encoding
set statusline +=\ \|\ %{strpart(&ff,0,1)}  " File format
set statusline +=\ \|\ %l:%c                " Total lines and virtual column number
set statusline +=\ \|\ %P                   " Percentage
set statusline +=\                          " Right margin (one space)

" ===== Syntax highlighting =====
syntax enable
set background =light
if !has('gui_running')
  set t_Co=256
endif
colorscheme solarized
set synmaxcol  =500             " Max column in which to search for syntax items (better performance)

" ===== Whitespace =====
set listchars=tab:»\ ,trail:•,extends:#,nbsp:.  " Highlight problematic whitespace

" ===== Fonts customization =====

" Row numbers
if (&background == 'light')
  hi LineNr guifg=#c2c0ba ctermfg=250
endif

" }}}
"  Completion {{{ ==============================================================

" inoremap <expr> <C-Space> pumvisible() \|\| &omnifunc == '' ?
"     \ "\<lt>C-n>" :
"     \ "\<lt>C-x>\<lt>C-o><C-r>=pumvisible() ?" .
"     \ "\"\\<lt>C-n>\\<lt>C-p>\\<lt>C-n>\" :" .
"     \ "\" \\<lt>bs>\\<lt>C-n>\"\<CR>"

inoremap <C-Space> <C-x><C-o>
imap <C-@> <C-Space>

" function to call when Ctrl-X Ctrl-O pressed in Insert mode
" if has("autocmd") && exists("+omnifunc")
"   autocmd Filetype *
"         \	if &omnifunc == "" |
"         \	setlocal omnifunc=syntaxcomplete#Complete |
"         \	endif
" endif

" Show menu when there is more then one item to complete
set completeopt=menu,preview

" Make <Tab> select the currently selected choice, same like <CR>
" If not in completion mode, call snippets expanding function
imap <expr> <Tab> pumvisible() ? "\<C-y>" : "<Plug>snipMateNextOrTrigger"
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<CR>"

" Compatibility with IDEA
inoremap <A-/> <c-n><Down>
inoremap <A-?> <c-p><Down>

" Close preview window
autocmd CompleteDone * pclose


" }}}
"  Global shortcuts {{{ ========================================================

" Initialize Yankstack plugin first
call yankstack#setup()

" ===== MapLeaders =====
" Set leader keys to ensure their assignment
" <Leader> for global shortcuts, <LocalLeader> for more specific and local usage
let mapleader = ','
let maplocalleader = "\<Space>"

"
" TEST
"

" Translate english word
nnoremap <Leader>tr :silent :OpenBrowser
      \ https://translate.google.com/?source=osdd#en/cs/
      \<C-r><C-w><CR>

nnoremap <A-t> vip:TransposeWords<CR>
nnoremap T" vip:s/"//g<CR>vip:TransposeWords<CR>
nnoremap T' vip:s/"//g<CR>vip:TransposeWords<CR>

" ===== Change indentation =====
nnoremap <A-S-H> <<
nnoremap <A-S-L> >>
vnoremap <A-S-H> <gv
vnoremap <A-S-L> >gv
if ! has('gui_running')
  nnoremap <Esc>H <<
  nnoremap <Esc>L >>
  vnoremap <Esc>H <gv
  vnoremap <Esc>L >gv
endif
" Maintain Visual Mode after shifting > and <
vnoremap < <gv
vnoremap > >gv

" ===== Command line =====
" Expand %% to path of current buffer in command mode
cnoremap <expr> %% getcmdtype() == ':' ? expand('%:h').'/' : '%%'

" ===== Consistency =====
" Make the behaviour of Y consistent with D and C
" (do the action from here to the end of line)
nnoremap Y y$

" ===== Cut, Copy and Paste =====
" copy selection
vnoremap <C-c> "+y
" copy whole document
nnoremap <C-c>a m`ggVG"*y``
" copy row
nnoremap <C-S-c> "+yy
nnoremap <C-c>r "+yy
" copy word
nnoremap <C-c>w m`viw"+y``
" copy WORD
nnoremap <C-c>W m`viW"+y``
" paste
nnoremap <C-V> "+p
" paste from insert mode
inoremap <C-V> <Esc>"+p
" paste over in visual mode
vnoremap <C-V> d"+gP
" Replace current word with yanked or deleted text (stamping)
nnoremap s "_diwPb
vnoremap s "_dP
" Don't yank the contents of an overwritten selection (reyank the original content)
" xnoremap p "_dP

" Yankstack
nmap <A-p> <Plug>yankstack_substitute_older_paste
nmap <A-n> <Plug>yankstack_substitute_newer_paste
if ! has('gui_running')
  nmap <Esc>p <Plug>yankstack_substitute_older_paste
  nmap <Esc>n <Plug>yankstack_substitute_newer_paste
endif

" ===== Execute (run) part of buffer =====
nnoremap <Leader>E :call ExecuteCurrentLine('bash -c')<CR>

" ===== Exiting =====
" Quit buffer without closing the window (plugin Bbye)
nnoremap Q :Bdelete<CR>
" Quit window
nnoremap <leader>q :q<CR>
" <C-z> minimizes gvim on Windows, which I dont like
nmap <C-z> <Esc>
" Close preview window more easily
nnoremap <S-Esc> :silent! pclose <Bar> cclose <Bar> lclose <Bar> NERDTreeClose<CR>

" ===== Headings =====
" Make commented heading from current line, using Commentary plugin (no 'noremap')
nmap <LocalLeader>+ O<ESC>65i=<ESC>gccjo<ESC>65i=<ESC>gccyiwk:center 64<CR>0Pjj
nmap <LocalLeader>- Oi<Esc>gcclDjgccwvUoi<Esc>gcclDj
nmap <LocalLeader>_ I<space><ESC>A<space><ESC>05i=<ESC>$5a=<ESC>gcc

" ===== Mouse buttons =====
" Set right mouse button to do paste
nnoremap <RightMouse> "*p
inoremap <RightMouse> <C-r>*
cnoremap <RightMouse> <C-r>*

" ===== Opening =====
" Open current document in browser (save it before)
nnoremap <leader>o :w<CR>:OpenInChrome<CR>

" ===== Open and reload $MYVIMRC =====
nnoremap <leader>V :split $MYVIMRC<CR>
nnoremap <A-s> :split $MYVIMRC<CR>
nnoremap <leader>VV :source $MYVIMRC<CR>

" ===== Plugin toggles =====
nnoremap <M-1> :NERDTreeFind<CR>
nnoremap <Esc>1 :NERDTreeFind<CR>
nnoremap <M-+> :NERDTreeFind<CR>
nnoremap <Esc>+ :NERDTreeFind<CR>
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <leader>G :Goyo<CR>

" ===== Programming shortcuts =====
" Switch end of line character
nnoremap <LocalLeader>; m`:s/;\?$/\=submatch(0) == ';' ? '' : ';'/<CR>``
nnoremap <LocalLeader>: m`:s/:\?$/\=submatch(0) == ':' ? '' : ':'/<CR>``
nnoremap <LocalLeader>, m`:s/,\?$/\=submatch(0) == ',' ? '' : ','/<CR>``

" ===== Saving buffer =====
" Use ctrl+s for saving, also in Insert mode (from mswin.vim)
noremap  <C-s> :update<CR>
vnoremap <C-s> <C-C>:update<CR>
inoremap <C-s> <Esc>:update<CR>
nnoremap coS :AutoSaveToggle<CR>

command! E normal :silent w<CR>:silent e<CR>

" ===== Searching and replacing =====

" Highlight current word and all same words (or selections)
" Case sensitive
nnoremap gr mmyiw/\C\<<C-r>"\><CR>:set hls<CR>`m
vnoremap gr y/\C<C-r>"<CR><C-o>:set hls<CR>gvo
" Case insensitive
nnoremap gR mmyiw/\c\<<C-r>"\><CR>:set hls<CR>`m
vnoremap gR y/\c<C-r>"<CR><C-o>:set hls<CR>gvo

" Change current word (or selection) and then every following one
" Case sensitive
nnoremap gy yiw/\C\<<C-r>"\><CR><C-o>:set hls<CR>cgn
vnoremap gy y/\C<C-r>"<CR><C-o>:set hls<CR>cgn
" Case insensitive
nnoremap gY yiw/\c\<<C-r>"\><CR><C-o>:set hls<CR>cgn
vnoremap gY y/\c<C-r>"<CR><C-o>:set hls<CR>cgn

" Go substitute
vnoremap gs y:set hls<CR>/<C-r>"<CR>``:%s/<C-r>"//g<Left><Left>
" Go substitute word
nnoremap gs :set hls<CR>:%s/\<<C-r><C-w>\>//g<Left><Left>
" Go count occurances
noremap gC m`:%s///gn<CR>``
" Go find from clipboard
noremap gB /<C-r>*<CR>:set hls<CR>:echo "Search from clipboard for: ".@/<CR>
" Go find from yank register
noremap g/ /<C-r>"<CR>:set hls<CR>:echo "Search from yank for: ".@/<CR>
" Go find last search pattern but as a whole word
nnoremap g> /\<<C-r>/\><CR>

" Per digit increment
nnoremap g<C-a> s<C-r>=<C-r>"+1<CR><Esc>

" Project wide search
nnoremap <C-f> :Ag<Space>
vnoremap <C-f> :<C-u>Ag<Space><C-r>*

" Interactive replace
nnoremap <M-S-R> :OverCommandLine<CR>%s/

" ===== Swaping =====
" Source http://vim.wikia.com/wiki/Swapping_characters,_words_and_lines
" Push current word after next one
nnoremap <silent> gp "_yiw:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o>/\w\+\_W\+<CR>:nohls<CR>
" Push current word before previous
nnoremap <silent> gP "_yiw?\w\+\_W\+\%#<CR>:s/\(\%#\w\+\)\(\_W\+\)\(\w\+\)/\3\2\1/<CR><c-o>:nohls<CR>

" ===== Bubble lines up and down =====
" Source http://vimrcfu.com/snippet/110
nnoremap <A-S-J> :m .+1<CR>==
nnoremap <A-S-K> :m .-2<CR>==
inoremap <A-S-J> <Esc>:m .+1<CR>==gi
inoremap <A-S-K> <Esc>:m .-2<CR>==g
vnoremap <A-S-J> :m '>+1<CR>gv=gv
vnoremap <A-S-K> :m '<-2<CR>gv=gv
if ! has('gui_running')
  nnoremap <Esc>J :m .+1<CR>==
  nnoremap <Esc>K :m .-2<CR>==
  inoremap <Esc>J <Esc>:m .+1<CR>==gi
  inoremap <Esc>K <Esc>:m .-2<CR>==g
  vnoremap <Esc>J :m '>+1<CR>gv=gv
  vnoremap <Esc>K :m '<-2<CR>gv=gv
endif


" Selects the text that was entered during the last insert mode usage
nnoremap gV `[v`]

" ===== Strings =====
" Surround current word
nnoremap <LocalLeader>" m`viw<esc>a"<esc>hbi"<esc>lel``
nnoremap <LocalLeader>' m`viw<esc>a'<esc>hbi'<esc>lel``
" Surround character with space
nnoremap g<Space> i<Space><Esc>la<Space><Esc>h
" Toggle between single and double quotes
nnoremap g' m`:s#['"]#\={"'":'"','"':"'"}[submatch(0)]#g<CR>``:set nohls<CR>
vnoremap g' m`:s#['"]#\={"'":'"','"':"'"}[submatch(0)]#g<CR>``:set nohls<CR>
" Toggle between backslashes and forward slashes
noremap <silent> g\ :ToggleSlash<CR>
" Toggle leading dash
noremap g- m`:s#^-\?\ *#\=submatch(0) == '- ' ? '' : '- '#g<CR>``

" ===== Function arguments =====
nmap ,[ <Plug>Argumentative_Prev
nmap ,] <Plug>Argumentative_Next
xmap ,[ <Plug>Argumentative_XPrev
xmap ,] <Plug>Argumentative_XNext
nmap ,< <Plug>Argumentative_MoveLeft
nmap ,> <Plug>Argumentative_MoveRight
xmap ia <Plug>Argumentative_InnerTextObject
xmap aa <Plug>Argumentative_OuterTextObject
omap ia <Plug>Argumentative_OpPendingInnerTextObject
omap aa <Plug>Argumentative_OpPendingOuterTextObject

" ===== Windows and Buffers =====
" Set working dir to current file dir, only for current window
nnoremap <leader>. :lcd %:p:h<CR>:echo "CWD changed to ".expand('%:p:h')<CR>

" Create new file in the directory next to the opened file
map <leader>n :e <C-R>=expand("%:p:h") . "/" <CR>

" Open previous buffer
noremap <C-\> :vsplit<CR>:bp<CR>
noremap <C-S-\> :split<CR>:bp<CR>

" Changing size of windows
nnoremap <C-Right> :vertical resize +2<CR>
nnoremap <C-Left> :vertical resize -2<CR>
nnoremap <C-Up> :resize +2<CR>
nnoremap <C-Down> :resize -2<CR>

" Set middle button to close tab
nnoremap <MiddleMouse> :tabclose<CR>

" ===== Moving in buffer =====
" Move commands acting on display lines
noremap j gj
noremap gj j
noremap k gk
noremap gk k

" ===== Moving in windows =====
" Cycling windows
nnoremap <S-Tab> <C-W>W
" Alt+LeftArrow to go back (also with side mouse button)
nnoremap <A-Left> ``
" Jump to left or right window
nmap <A-l> <C-w>l
nmap <A-h> <C-w>h
nmap <A-j> <C-w>j
nmap <A-k> <C-w>k
if ! has('gui_running')
  nmap <Esc>l <C-w>l
  nmap <Esc>h <C-w>h
  nmap <Esc>j <C-w>j
  nmap <Esc>k <C-w>k
endif
" Move screen 10 characters left or right in wrap mode
nnoremap gh 40zh
nnoremap gl 40zl
" Jump around methods
nnoremap <C-j> ]m^
"nnoremap <C-k> [m^
" Hide every except current window
nnoremap <C-S-F12> :only<CR>
nnoremap <C-F12> :echo 'outline'<CR>

" ===== Wrap mode =====
" change wrap and set or unset bottom scroll bar
nnoremap <expr> <leader>w ':set wrap! go'.'-+'[&wrap]."=b\r"

" ===== Location and quickfix windows =====
let g:toggle_list_no_mappings=1
nmap <script> <silent> coa :call ToggleLocationList()<CR>
nmap <script> <silent> coq :call ToggleQuickfixList()<CR>

" ===== Diff =====
nmap <F7> ]c
nmap <S-F7> [c


" }}}
"  Appearance shortcuts {{{ ====================================================

" ===== Font size =====
if has('gui_running')
    nnoremap <C-kMinus> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) - 1)', '')<CR>
    nnoremap <C-kPlus> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) + 1)', '')<CR>
endif

" ===== Highlighting =====
" Show highlight groups under cursor
noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
      \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . "> fgcolor<"
      \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg") . ">"<CR>

" }}}
"  General commands {{{ ========================================================


" ===== Bufferize =====
" Print output of MORE viewer into buffer
command! -nargs=* -complete=command Bufferize call s:Bufferize(<q-args>)
" Put output of a command into current buffer
command! -nargs=* -complete=command Echo call s:Echo(<q-args>)

" ===== Closing =====
" Closes all buffers except the active one
command! Bonly :call CloseAllBuffersButActive()

" ===== Diff =====
" Vertical diff
command! Dv :vertical diffsplit
" Diff all opened
command! Da :windo diffthis
" Diff off all opened
command! Do :windo diffoff

" ===== Extract matches =====
" Extract the matches of last search from current buffer
command! Extract :%Yankitute//&/g
" Extract matching lines into new buffer (http://vim.wikia.com/wiki/VimTip1063)
command! -nargs=? Filter let @a='' | execute 'g/<args>/y A' | new | setlocal bt=nofile | put! a

" ===== Lists =====
" Creates Perl style list definition from paragraph of items on lines
command! -nargs=* Tolist call MakeListFromLines(<q-args>)
command! -nargs=* Tolistclear call MakeClearListFromLines(<q-args>)
" Reverse from the list to lines
command! Tolines :call MakeLinesFromList()
command! Tolinesclear :call MakeClearLinesFromList()

" ===== Open buffer in =====
" Open current document in browser (save it before)
command! OpenInFirefox :call OpenCurrentDocumentInBrowser('firefox')
command! OpenInChrome :call OpenCurrentDocumentInBrowser('chrome')
command! OpenInVivaldi :call OpenCurrentDocumentInBrowser('vivaldi')

if has('win32')
  let g:openbrowser_browser_commands = [
        \   {'name': 'rundll32',
        \    'args': 'rundll32 url.dll,FileProtocolHandler {use_vimproc ? uri : uri_noesc}'},
        \   {'name': 'C:\Program Files (x86)\Google\Chrome\Application\chrome.exe',
        \    'args': ['start', '{browser}', '{uri}']}
        \]
  let g:openbrowser_use_vimproc=0
endif

" ===== Repeated lines =====
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
command! UnHighlight syn clear Repeat

" ===== Strips tags from buffer =====
command! StripTags call StripTags()

" ===== Strip trailing whitespaces =====
command! StripTrailingWhitespace :call StripTrailingWhitespace()
command! STW :call StripTrailingWhitespace()

" ===== XML and Xpath =====
" Rewrite the buffer with xpath matches only
command! -nargs=1 Xpath :call Xpath(<args>)
command! XMLNewLines call XMLNewLines()
command! XMLSimplify :silent call XMLSimplify()

" }}}
"  Filetype specific commands {{{ ==============================================

" Common shortcuts
" <leader>c = compile
" <leader>e = run current line
" <leader>E = run current line with output in split window
" <leader>r = run buffer or selection
" <leader>R = run buffer or selection with output in split window
" <leader>t = run test
" <leader>R = run test with output in split window
" <leader>k = check style
" <leader>f = format file
" <C-CR>    = run current block or line
" <c-b>     = go to declaration

nnoremap <c-h> K
nnoremap <F2> :cnext<CR>
nnoremap <S-F2> :cprevious<CR>
nnoremap <F3> :lnext<CR>
nnoremap <S-F3> :lprevious<CR>

" ===== Misc filetypes =====

augroup GLOBAL
  autocmd!
  " Cursor on last editing place in every opened file
  autocmd BufReadPost * normal `"
augroup END

augroup EDITING
  autocmd!
  " Make it so that a curly brace automatically inserts an indented line
  autocmd FileType javascript,typescript,css,perl,php,java inoremap {<CR> {<CR>}<Esc>O
augroup END

augroup CSS
  autocmd FileType css set omnifunc=csscomplete#CompleteCSS
  autocmd BufRead,BufNewFile *.css :ColorSwapFgBg
augroup END

augroup DOSBATCH
  autocmd!
  autocmd FileType dosbatch set formatoptions -=o
  " Run dosbatch bat file
  autocmd FileType dosbatch nnoremap <C-CR> ^y$:!<C-r>"<CR>
  autocmd FileType dosbatch nnoremap <buffer> <leader>r :w<CR>:Clam %:p<CR>gg<C-w>w
augroup END

augroup HTML
  autocmd!
  autocmd BufRead,BufNewFile *.cshtml set filetype=html
  autocmd FileType html,xml setlocal tabstop=2
  autocmd FileType html,xml setlocal softtabstop=2
  autocmd FileType html,xml setlocal shiftwidth=2
  autocmd FileType html,xml setlocal smartindent
  autocmd FileType html nnoremap <C-b> :call JumpToCSS()<CR>

  " previous tag on same indentation level
  autocmd FileType html,xml nnoremap <C-k> ?^\s\{<C-r>=indent(".")<CR>}\S\+<CR>nww
  " next tag on same indentation level
  autocmd FileType html,xml nnoremap <C-j> /^\s\{<C-r>=indent(".")<CR>}\S\+<CR>ww
  " Given <tag>|</tag> when <CR> then jump to next line
  autocmd FileType html,xml inoremap <expr> <CR> Expander()
  " Comp
  autocmd FileType html,xhtml setlocal omnifunc=htmlcomplete#CompleteTags
augroup END

augroup GNUPLOT
  autocmd!
  " Compile gnuplot graph
  autocmd FileType gnuplot nnoremap <buffer> <leader>c :w<CR>:silent !cmd /c gnuplot -p %<CR>
  autocmd FileType gnuplot setlocal commentstring=#\ %s
  " Set filetype automatically
  autocmd BufRead,BufNewFile *.plt set filetype=gnuplot
augroup END

augroup JAVA
  autocmd!
  autocmd BufRead,BufNewFile *.jshell set filetype=java
  autocmd BufRead,BufNewFile *.jsh set filetype=java
  autocmd Filetype java set makeprg=javac\ -cp\ \".;*\"\ %
  autocmd Filetype java set errorformat=%A%f:%l:\ %m,%-Z%p^,%-C%.%#
  autocmd Filetype java nnoremap <buffer> <leader>c :call MyMake()<CR>
  autocmd Filetype java nnoremap <buffer> <leader>r :call MakeAndRun('java -cp ".;*"', '')<CR>
  autocmd Filetype java nnoremap <buffer> <leader>R :call MakeAndRunClam('java -cp ".;*"', '')<CR>
augroup END

augroup JAVASCRIPT
  autocmd!
  autocmd FileType javascript,json setlocal tabstop=2
  autocmd FileType javascript,json setlocal softtabstop=2
  autocmd FileType javascript,json setlocal shiftwidth=2

  autocmd Filetype javascript nnoremap <C-j> j/=\? \?fun<CR>:set nohls<CR>:let @/ = ""<CR>0
  autocmd Filetype javascript nnoremap <C-k> /=\? \?fun<CR>N:set nohls<CR>:let @/ = ""<CR>0
  autocmd Filetype javascript nnoremap <leader>f :Autoformat<CR>
  autocmd Filetype javascript nnoremap <leader>e :call ExecuteCurrentLine('node -e')<CR>
  autocmd Filetype javascript nnoremap <leader>r :call MyRun('node')<CR>
  autocmd Filetype javascript vnoremap <leader>r <Esc>:call ExecuteVisualSelection('node -e')<CR>
  autocmd FileType javascript nnoremap <leader>R :call MyRunClam('node')<CR>
  autocmd FileType javascript vnoremap <leader>R <Esc>:call ExecuteVisualSelectionWithOutput('node')<CR>
  autocmd FileType javascript nnoremap <leader>t :!npm test --silent %<CR>
  autocmd FileType javascript nnoremap <leader>T :!npm test --silent --recursive<CR>
augroup END

augroup TYPESCRIPT
  au!
  autocmd FileType typescript call SetupFiletype_TypeScript()
augroup END
fun! SetupFiletype_TypeScript()
  setlocal tabstop=2
  setlocal softtabstop=2
  setlocal shiftwidth=2
  setlocal makeprg=tsc\ --target=es5\ $*\ %
  JsPreTmpl html
  nnoremap <buffer> <leader>r :call MakeAndRun('node', 'js')<CR>
  nnoremap <buffer> <leader>R :call MakeAndRunClam('node', 'js')<CR>
  nnoremap <buffer> <leader>c :call MyMake()<CR>
  nnoremap <buffer> <C-g> :TsuSearch<Space>
  nnoremap <buffer> <C-b> :TsuDefinition<CR>
  nnoremap <buffer> <C-S-G> :TsuReferences<CR>
  nnoremap <buffer> <A-F7> :TsuReferences<CR>
  nnoremap <buffer> <Esc><F7> :TsuReferences<CR>
  nnoremap <buffer> <S-F6> :TsuquyomiRenameSymbol<CR><C-r><C-w>
  nnoremap <buffer> <C-h> : <C-u>echo tsuquyomi#hint()<CR>
endfun

augroup JSON
  autocmd!
  autocmd Filetype json nnoremap <leader>f :%!python -m json.tool<CR>
augroup END

augroup JIRA
  autocmd!
  " Set filetype automatically
  autocmd BufRead,BufNewFile *.jira setlocal filetype=jira
augroup END

" Create Jira style aligned table from tab separated items of one paragraph
" First line will have double | (pipe) characters as separators
command! TTabToJira normal
      \ vip:s/\t/|/g<CR>
      \ vip:s/^/|\ /<CR>
      \ vip:s/$/\ |/<CR>
      \ vip:Tabularize/|<CR>
      \ {j:s/|\ \?/||/g<CR>

" Create Jira style table from MySQL console output
command! TMysqlToJira normal vap:g/^+/d<CR>kvipo<ESC>:s/\ \?|/||/g<CR>

augroup MARKDOWN
  autocmd!
  autocmd FileType modula2  setlocal ft         =markdown
  autocmd FileType markdown nnoremap <C-j> /^#<CR>
  autocmd FileType markdown nnoremap <C-k> ?^#<CR>
  autocmd FileType markdown setlocal formatoptions=jlnr1
  autocmd FileType markdown setlocal comments=b:*,b:+,n:>,b:-

  autocmd FileType markdown command! Outline :Voom markdown

  " From dash separated heading to spaces and capital letter
  autocmd FileType markdown nnoremap <LocalLeader>h :s/-/\ /g<CR>~h

  " Prefix # heading
  autocmd FileType markdown nnoremap <LocalLeader>0 m`:s/^\(#*\)\ \?//<CR>``
  " Underline H1
  autocmd FileType markdown nnoremap <LocalLeader>1 yypVr=<Esc>
  autocmd FileType markdown nnoremap <LocalLeader>2 m`:s/^\(#*\)\ \?/##\ /<CR>``
  autocmd FileType markdown nnoremap <LocalLeader>3 m`:s/^\(#*\)\ \?/###\ /<CR>``
  autocmd FileType markdown nnoremap <LocalLeader>4 m`:s/^\(#*\)\ \?/####\ /<CR>``
  " bold
  autocmd FileType markdown nnoremap <LocalLeader>b viw<Esc>`>a**<Esc>`<i**<Esc>f*;
  autocmd FileType markdown vnoremap <LocalLeader>b <Esc>`>a**<Esc>`<i**<Esc>f*;
  " italics
  autocmd FileType markdown nnoremap <LocalLeader>i viw<Esc>`>a_<Esc>`<i_<Esc>f_
  autocmd FileType markdown vnoremap <LocalLeader>i <Esc>`>a_<Esc>`<i_<Esc>f_
  " inline code
  autocmd FileType markdown nnoremap <LocalLeader>` viw<Esc>`>a`<Esc>`<i`<Esc>f`
  autocmd FileType markdown vnoremap <LocalLeader>` <Esc>`>a`<Esc>`<i`<Esc>f`
  " fenced code block
  autocmd FileType markdown nnoremap <LocalLeader>9 vip<Esc>`<O```<Esc>`>o```<Esc>j
  autocmd FileType markdown vnoremap <LocalLeader>9 <Esc>`<O```<Esc>`>o```<Esc>j
  " quoutes
  autocmd FileType markdown nnoremap <LocalLeader>> vip<C-q>0I><space><Esc>
  autocmd FileType markdown vnoremap <LocalLeader>> <C-q>0I><space><Esc>
  " unordered list
  autocmd FileType markdown nnoremap <LocalLeader>u vip:s/^\(\s*\)/\1- /<CR>
  autocmd FileType markdown vnoremap <LocalLeader>u :s/^\(\s*\)/\1- /<CR>
  " quoute
  autocmd FileType markdown nnoremap <LocalLeader>q m`vip:s/^/> /<CR>``
  autocmd FileType markdown vnoremap <LocalLeader>q m`:s/^/> /<CR>``

  " Save mkd file
  autocmd FileType markdown nnoremap <LocalLeader>s :1y<CR> :w <C-r>"<BS>.md
  " Link from address - last segment to be the text - select the text
  autocmd FileType markdown nnoremap <LocalLeader>l :s/\v((https?\|www).*\/)([^\/ \t)]+)(\/?)/[\3](&)/<CR>vi[<C-g>
  " Link from link text and link itself on the next line
  autocmd FileType markdown nnoremap <LocalLeader>L A]<Esc>I[<Esc>jA)<Esc>I(<Esc>kJx0

augroup END

" Creates Markdown (GFM) style table from tab separated items of one paragraph
" Second line will be a separator between head and body of the table
command! MDtable normal
      \ vip:s/\t/|/g<CR>
      \ vip:Tabularize/|<CR>
      \ yyp:s/[^ |]/-/g<CR>
      \ :s/\([^|]\)\ \([^ |]\)/\1-\2/g<CR>

" Create Markdown ordered list
" Adds numbers and align the list
command! MDlist normal
      \ vipI1. }k
      \ :Tabularize/^[^ ]*\zs\ /l0

" Create Markdown main heading from file name
command! MDfiletohead normal
      \ ggOi%dF.x0vU
      \ :s/-/\ /g<CR>
      \ yypVr=o

" Creates Markdown style web links
" Replaces any row and following row with URL with Markdown syntax for links
command! MDlinks %s/\(.*\)\n\(\(http\|www\).*\)/[\1](\2)/

" ===== Pascal =====
augroup pascal
  autocmd!
  " Comments for pascal
  autocmd FileType pascal setlocal commentstring={%s}
  " Compile pascal with FPC
  autocmd FileType pascal noremap <buffer> <leader>c
        \:w<CR>:silent !cmd /c "c:\Program Files (x86)\FPC\bin\i386-win32\fpc.exe" %<CR>
  " Run pascal program
  autocmd FileType pascal noremap <buffer> <leader>r
        \:w<CR>:execute "!" . expand('%:s?pas?exe?:p')<CR>
augroup END

" ===== Perl =====
augroup perl
  autocmd!
  " Show output of perl script (save, open Clam window, switch back to script window)
  autocmd FileType perl noremap <buffer> <leader>c :w<CR>:Clam perl %<CR>G<C-w>w
  autocmd FileType perl noremap <buffer> <leader>ca :w<CR><C-w>wggO<Esc>:0r!perl -w #<CR><C-w>w
augroup END

" ===== PHP =====
augroup php
  autocmd!
  " Set filetype automatically
  autocmd BufRead,BufNewFile *.latte setlocal filetype=latte
augroup END

" ===== Python =====
augroup python
  autocmd!
  autocmd FileType python setlocal textwidth =79
  autocmd FileType python setlocal tabstop   =4

  autocmd FileType python noremap <leader>f :Autoformat<CR>
  autocmd FileType python noremap <leader>k :PymodeLint<CR>

  autocmd FileType python noremap <leader>f :Autoformat<CR>
  autocmd FileType python noremap <leader>k :PymodeLint<CR>

  if has('win32')
    autocmd FileType python noremap <buffer> <leader>h :!python -m pydoc <C-r><C-w><CR>
  endif
  if has('unix')
    autocmd FileType python noremap <buffer> <leader>h :!pydoc <C-r><C-w><CR>
  endif
  autocmd FileType python nnoremap <buffer> <leader>R :w<CR>:silent !python %<CR>
  autocmd FileType python nnoremap <buffer> <leader>r :w<CR>:Clam python %<CR><C-w>h
  autocmd FileType python vnoremap <buffer> <leader>r :ClamVisual python<CR>
augroup END

" ===== SHELL and BASH and ZSH =====
augroup sh
  autocmd!
  autocmd BufRead,BufNewFile *.bash set filetype=sh
  autocmd BufRead,BufNewFile *.zsh set filetype=sh
  autocmd BufRead,BufNewFile *.bash set fileformat=unix
  autocmd BufRead,BufNewFile *.sh set fileformat=unix
  autocmd BufRead,BufNewFile *.zsh set fileformat=unix

  if getline(1) =~ ".*env sh"
    let b:shell = 'sh'
  elseif getline(1) =~ ".*env zsh"
    let b:shell = 'zsh'
  else
    let b:shell = 'bash'
  endif

  autocmd FileType sh nnoremap <Leader>e :call ExecuteCurrentLine('bash')<CR>
  autocmd FileType sh nnoremap <Leader>E V:<C-w>BexecVisual()<CR><Esc>
  autocmd FileType sh nnoremap <Leader>r :Bexec<CR>
  autocmd FileType sh vnoremap <Leader>r :<C-w>BexecVisual()<CR>
  autocmd FileType sh nnoremap <Leader><Esc> :BexecCloseOut<CR>
  if has('win32')
    " Using git-for-windows executable
    autocmd FileType sh nnoremap <Leader>r :w<CR>:!bash %<CR>
  endif
augroup END


" ===== SQL =====
augroup sql
  autocmd!
  " Set filetype automatically
  autocmd BufRead,BufNewFile *.ddl setlocal filetype=sql

  " SQL comments
  autocmd FileType sql setlocal commentstring=--\ %s

  autocmd FileType sql nnoremap <LocalLeader>r :w<CR>:call HowLong("DBExecSQLUnderCursor")<CR>
  autocmd FileType sql vnoremap <Leader>r <Plug>DBExecVisualSQL

  " Spaces works better then tabs for MySQL
  autocmd Filetype sql setlocal expandtab
  " Upper case
  autocmd Filetype sql noremap <LocalLeader>u :s/\<distinct\>\\|\<having\>\\|\<update\>\\|\<select\>\\|\<delete\>\\|\<insert\>\\|\<from\>\\|\<where\>\\|\<join\>\\|\< left join\>\\|\<inner join\>\\|\<on\>\\|\<group by\>\\|\<order by\>\\|\<and\>\\|\<or\>\\|\<as\>/\U&/ge<CR><esc>
  " New lines before and after keywords
  autocmd Filetype sql noremap <LocalLeader>f :s/\(\(\ \{4}\)*\)\(\<update\>\\|\<from\>\\|\<where\>\\|\<group by\>\\|\<order by\>\\|;\)\ /\r&\r\1\ \ \ \ /ge<CR>:s/\<join\>/\r\ \ \ \ &/g<CR>
augroup END

" ===== VBA =====
augroup vba
  autocmd!
  " Do not count ' as quotes
  autocmd FileType vb let b:delimitMate_quotes = "\" `"
augroup END

" Opens browser with Microsoft MSDN search for current key word
command! MSDN :silent :OpenBrowser
      \ http://social.msdn.microsoft.com/Search/en-US?query=
      \ <C-r><C-w><CR>

" ===== VIM =====
autocmd Filetype vim setlocal ts=2 sts=2 sw=2
autocmd Filetype vim setlocal foldmethod=marker

" ===== XML (and HTML) =====
augroup xml
  autocmd!
  autocmd FileType xml nnoremap <leader>f :%!xmlstarlet fo -s 4<CR>
  autocmd FileType xml vnoremap <leader>f :!xmlstarlet fo -s 4<CR>
  " check if XML is wellformed
  command! Wellformed :!xmllint --noout %<CR>
augroup END


augroup YAML
  autocmd!
  autocmd FileType yaml setlocal tabstop=2
  autocmd FileType yaml setlocal softtabstop=2
  autocmd FileType yaml setlocal shiftwidth=2
augroup END

" }}}
"  Plugin settings {{{ =========================================================

" ===== Ag =====
let g:ag_prg="ag --vimgrep --smart-case"
let g:ag_highlight=1
let g:ag_working_path_mode='r'

" ===== Angular-cli =====
autocmd VimEnter * if globpath('.,..','node_modules/@angular') != '' | call angular_cli#init() | endif
let g:angular_cli_stylesheet_format = 'scss'
let g:angular_cli_use_dispatch = 1


" ===== Autoformat =====
" sql - Indent String is 4 space and enable Trailing Commas
let g:formatdef_my_sql = 'sqlformatter /is:"    " /tc /uk /sk-'
let g:formatters_sql = ['my_sql']
let g:formatdef_autopep8 = "'autopep8 - --range '.a:firstline.' '.a:lastline"
let g:formatters_python = ['autopep8']

" ===== Autosave vim-auto-save =====
let g:auto_save_in_insert_mode = 0
let g:auto_save_silent = 1
augroup AUTOSAVE
  autocmd!
  autocmd FileType javascript,typescript,html,css let g:auto_save = 1
augroup END

" ===== Colorizer =====
let g:colorizer_auto_filetype='css,html,conf,javascript,typescript'
let g:colorizer_x11_names = 1

" ===== CtrlP =====
" Set ctrl+p for normal fuzzy file opening
nnoremap <C-p> :CtrlPCurWD<CR>

nnoremap <C-e> :CtrlPMRUFiles<CR>

nnoremap <C-Tab> :CtrlPBuffer<CR>

let g:ctrlp_custom_ignore = {
      \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site|target|node_modules|bower_components|dist)$',
      \ 'file': '\v\.(exe|so|dll|class|png|jpg|jpeg)$'
      \}
let g:ctrlp_working_path_mode = 'rc'

" ===== CSV =====
" let g:csv_no_conceal = 1 " Do not show | instead of ,
" let g:csv_no_column_highlight = 1
hi def link CSVColumnHeaderOdd  vimCommentString
hi def link CSVColumnHeaderEven vimCommentString
hi def link CSVColumnOdd        vimSynMtchOpt
hi def link CSVColumnEven       normal
" Trick to switch CSV plugin on when set to file type 'csvx' by Plug
command! CSVON let &ft='csvx' | let &ft='csv'

" ===== dbext =====
let g:dbext_default_window_use_horiz = 0  " Use vertical split
let g:dbext_default_window_width = 120
let g:dbext_default_always_prompt_for_variables = -1
let g:dbext_default_MYSQL_extra = '-vv -t'
if has('win32')
  let g:dbext_default_history_file = '~/vimfiles/dbext_history'
elseif has('unix')
  let g:dbext_default_history_file = '~/.vim/dbext_history'
endif

" ===== DelimitMate =====
let g:delimitMate_expand_cr    = 2  " Expand to new line after <CR>
let g:delimitMate_expand_space = 1  " Expand the <space> on both sides
" let g:delimitMate_autoclose  = 0  " Do not add closing delimeter automatically
" let g:delimitMate_offByDefault = 1  " Turn off by default
let delimitMate_excluded_ft = "markdown,txt,sh"
" Run :DelimitMateSwitch to turn on

" ===== EditorConfig =====
let g:EditorConfig_exclude_patterns = ['fugitive://.*', 'scp://.*']

" ===== Emmet =====
let g:user_emmet_leader_key = '<C-y>'
let g:user_emmet_mode='in'
let g:emmet_html5           = 1

" ===== Fugitive =====
augroup fugitive
  autocmd!
  " [Source](http://vimcasts.org/episodes/fugitive-vim-browsing-the-git-object-database/)
  " delete fugitive buffer from buffer list when no longer visible
  autocmd BufReadPost fugitive://* setlocal bufhidden=delete

  " Go up a level in git tree
  autocmd User fugitive
        \ if fugitive#buffer().type() =~# '^\%(tree\|blob\)$' |
        \   nnoremap <buffer> .. :edit %:h<CR> |
        \ endif

  nnoremap <Leader>ga :Git add %:p<CR><CR>
  nnoremap <Leader>gs :Gstatus<CR>
  nnoremap <Leader>gc :Gcommit -v -q<CR>
  nnoremap <Leader>gt :Gcommit -v -q %:p<CR>
  nnoremap <Leader>gd :Gdiff<CR>
  nnoremap <Leader>gdh :Gdiff -<CR>
  nnoremap <Leader>gdd :Git! diff<CR>
  nnoremap <Leader>gds :Git! diff --staged<CR>
  nnoremap <Leader>ge :Gedit<CR>
  nnoremap <Leader>gr :Gread<CR>
  nnoremap <Leader>gw :Gwrite<CR><CR>
  nnoremap <Leader>gl :silent! Glog<CR>:bot copen<CR>
  nnoremap <Leader>gp :Ggrep<Space>
  nnoremap <Leader>gm :Gmove<Space>
  nnoremap <Leader>gb :Git branch<Space>
  nnoremap <Leader>go :Git checkout<Space>
  nnoremap <Leader>gv :Gitv<CR>
  nnoremap <Leader>gf :Gitv!<CR>
  command! History :Gitv!<CR>
  command! Log :Gitv<CR>
augroup END

" ===== GitGutter =====
let g:gitgutter_enabled = 0
let g:gitgutter_signs = 1
nmap <Leader>ht :GitGutterToggle<CR>
nmap <Leader>hl :GitGutterLineHighlightsToggle<CR>
nmap <Leader>hs <Plug>GitGutterStageHunk
nmap <Leader>hu <Plug>GitGutterUndoHunk
nmap <C-z> <Plug>GitGutterUndoHunk
nmap <F7> <Plug>GitGutterNextHunk
nmap <S-F7> <Plug>GitGutterPrevHunk
nmap ]c <Plug>GitGutterNextHunk
nmap [c <Plug>GitGutterPrevHunk
nmap <C-F7> :call ToggleHunkPreview()<CR>
nmap <Leader>hp :call ToggleHunkPreview()<CR>
fun! ToggleHunkPreview()
  let l:isTherePreviewWindow = 0
  for nr in range(1, winnr('$'))
    if getwinvar(nr, "&pvw") == 1
      let l:isTherePreviewWindow = 1
    endif
  endfor
  if l:isTherePreviewWindow == 1
    silent execute "pclose"
  else
    silent execute "GitGutterPreviewHunk"
  endif
endf

" ===== Goyo =====
let g:goyo_width=100 "(default: 80)
let g:goyo_margin_top=2 " (default: 4)
let g:goyo_margin_bottom=2 " (default: 4)

" ===== json =====
let g:vim_json_syntax_conceal = 0

" ===== javascript-libraries-syntax =====
let g:used_javascript_libs = 'angular,angularjs,angularui,angularuirouter,jasmine,chai,react,d3'

" ===== LogViewer =====
let g:LogViewer_Filetypes = 'log'

" ===== Open browser =====
" If it looks like URI, open an URI under cursor.
" Otherwise, search a word under cursor.
nmap <F6> <Plug>(openbrowser-smart-search)
vmap <F6> <Plug>(openbrowser-smart-search)


" ===== Markdown =====
" let g:markdown_fenced_languages = ['bat=dosbatch', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'java', 'sql', 'sh']
let g:markdown_enable_spell_checking = 0
let g:markdown_enable_conceal = 1

" ===== Multiple cursors =====
let g:multi_cursor_exit_from_visual_mode = 0
let g:multi_cursor_exit_from_insert_mode = 0
let g:multi_cursor_next_key='<C-m>'
nnoremap <Leader>m :MultipleCursorsFind <C-r><C-w><CR>

" ===== NERDTree =====
let NERDTreeChDirMode=2
let NERDTreeQuitOnOpen=1
let NERDTreeIgnore=['\.pyc$', '\~$', '__\.pyc$']
" NerdTree - git
let g:NERDTreeIndicatorMapCustom = {
      \ 'Modified'  : '~',
      \ 'Staged'    : '+',
      \ 'Untracked' : '*',
      \ 'Renamed'   : '»',
      \ 'Unmerged'  : '=',
      \ 'Deleted'   : '-',
      \ 'Dirty'     : '×',
      \ 'Clean'     : '"',
      \ 'Ignored'   : 'o',
      \ 'Unknown'   : '?'
      \ }

" ===== Pymode =====
let g:pymode_lint_on_write = 0
let g:pymode_rope_complete_on_dot = 0
let g:pymode_rope_autoimport_import_after_complete = 1
let g:pymode_syntax_all =1
let g:pymode_rope_project_root = "~/.ropeproject"
let g:pymode_options_colorcolumn = 0

" ===== Restart =====
let g:restart_sessionoptions = "restartsession"

" ===== SetExecutable =====
command! SetExecutable :call SetExecutable()<CR>

" ===== Snipmate =====
imap <C-t> <Plug>snipMateShow
let g:snipMate = get(g:, 'snipMate', {}) " Allow for vimrc re-sourcing
let g:snipMate.scope_aliases = {}
let g:snipMate.scope_aliases['html'] = 'bootstrap4'

" ===== SuperTab =====
" let g:SuperTabMappingForward = '<C-space>'
" let g:SuperTabMappingBackward = '<S-C-space>'
" let g:SuperTabDefaultCompletionType = '<C-n>'
" let g:SuperTabDefaultCompletionType = '<C-x><C-o>'
" let g:SuperTabLongestHighlight = 0

" ===== Syntastic =====
let g:syntastic_mode_map = {
      \ "mode": "passive",
      \ "active_filetypes": [],
      \ "passive_filetypes": [] }

" ===== Table Mode =====
let g:table_mode_corner     = "|"
let g:table_mode_align_char = ":"

" ===== Tsuquyomi =====
let g:tsuquyomi_disable_quickfix = 1
let g:tsuquyomi_completion_detail = 1
let g:tsuquyomi_javascript_support = 1

" ===== Vim-markdown =====
let g:vim_markdown_folding_disabled=1

" ===== Voom =====
let g:voom_tree_placement = "right"
command! Outline :Voom

" ===== Xml.vim =====
" let xml_tag_completion_map = "<C-l>"
let g:xml_warn_on_duplicate_mapping = 1
let xml_no_html = 1

" ===== Zeavim - Zeal integration =====
let g:zv_zeal_directory = "C:\\Program Files (x86)\\zeal\\zeal.exe"

" }}}
"  Utility functions {{{ ===============================================================

fun! ExecuteCurrentLine(program)
  silent let s = system( a:program . ' ' . shellescape(getline(".")) )
  echo s
endf

fun! ExecuteVisualSelection(program)
  silent let s = system( a:program . ' ' . shellescape(join(getline("'<", "'>"))) )
  echo s
endf

fun! ExecuteVisualSelectionWithOutput(program)
  execute "'<,'>Clam " . a:program
  call cursor('$', 1)
  wincmd w
endf

fun! ExecuteCurrentBuffer(program)
  silent write
  let stdin = join(getline(1,'$'), "\n")
  let s = system(a:program, stdin)
  echo s
endf

fun! ExecuteCurrentBufferWithOutput(program)
  silent write
  execute 'Clam ' . a:program . ' %'
  call cursor('$', 1)
  wincmd w
endf

function! RunJavaWithOutput()
  silent write
  lcd %:p:h
  silent! make
  botright cwindow
  normal <CR>
  if (len(getqflist()) < 1)
    Clam java %:r
    wincmd w
  endif
  redraw!
endfunction

function! RunJava()
  silent write
  lcd %:p:h
  silent! make
  botright cwindow
  normal <CR>
  if (len(getqflist()) < 1)
    let s = system('java ' . expand('%:r'))
    echo ' '
    echo s
    echo ' '
  endif
endfunction

function! MakeAndRun(...)
  call MyMake()
  " If no errors run
  if (len(getqflist()) < 1)
    " Pass the first optional argument
    call call("MyRun", a:000)
  endif
endfunction

function! MakeAndRunClam(...)
  call MyMake()
  " If no errors run
  if (len(getqflist()) < 1)
    " Pass the first optional argument
    call call("MyRunClam", a:000)
  endif
endfunction

function! MyMake()
  silent write
  lcd %:p:h
  silent! make
  botright cwindow
  normal <CR>
endfunction

function! MyRun(...)
  silent write
  if (a:0 < 1)
    let l:out = "Missing first argument: the interpreter name."
  elseif (a:0 == 1)
    let l:interpreter = a:1
    let l:out = system(l:interpreter . ' ' . expand('%'))
  elseif (a:0 == 2)
    " When given extra argument, run with it as different extension,
    " or no extension at all, it is an empty string
    let l:interpreter = a:1
    let l:extension = a:2
    if (l:extension == '')
      let l:out = system(l:interpreter . ' ' . expand('%:r'))
    else
      let l:out = system(l:interpreter . ' ' . expand('%:r') . '.' . l:extension)
    endif
  elseif (a:0 > 2)
    let l:out = "Too many arguments."
  endif
  echo ' '
  echo l:out
  echo ' '
endfunction

function! MyRunClam(...)
  silent write
  if (a:0 < 1)
    echo "Missing first argument: the interpreter name."
  elseif (a:0 == 1)
    let l:interpreter = a:1
    exe 'Clam ' . l:interpreter . ' ' . expand('%')
    call cursor('$', 1)
    wincmd w
  elseif (a:0 == 2)
    " When given extra argument, run with it as different extension,
    " or no extension at all, it is an empty string
    let l:interpreter = a:1
    let l:extension = a:2
    if (l:extension == '')
      exe 'Clam ' . l:interpreter . ' ' . expand('%:r')
      call cursor('$', 1)
      wincmd w
    else
      exe 'Clam ' . l:interpreter . ' ' . expand('%:r') . '.' . l:extension
      call cursor('$', 1)
      wincmd w
    endif
  elseif (a:0 > 2)
    echo "Too many arguments."
  endif
endfunction


function! OpenCurrentDocumentInBrowser(browser)
  call system("cmd.exe /c start " . a:browser . " \"file:///" . substitute(expand("%:p"), "\ ", "%20", "g") . "\"" )
endfunction

" Strip whitespace
function! StripTrailingWhitespace()
  " Preparation: save last search, and cursor position.
  let _s=@/
  let l = line(".")
  let c = col(".")
  " do the business:
  %s/\s\+$//e
  " clean up: restore previous search history, and cursor position
  let @/=_s
  call cursor(l, c)
endfunction

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r # | 0d_ | diffthis
        \ | wincmd p | diffthis
endif

" Word Frequency function creates new file with words and their frequencies
function! WordFrequency() range
  let all = split(join(getline(a:firstline, a:lastline)), '\A\+')
  let frequencies = {}
  for word in all
    let frequencies[word] = get(frequencies, word, 0) + 1
  endfor
  new
  setlocal buftype=nofile bufhidden=hide noswapfile tabstop=20
  for [key,value] in items(frequencies)
    call append('$', key."\t".value)
  endfor
  sort i
endfunction
command! -range=% WordFrequency <line1>,<line2>call WordFrequency()

" Simplifies structured (one tag per line) xml document for better clarity
function! XMLSimplify()
  " remove end tags
  %s/<\/[^>]*>//g
  " remove everything after first tag on line
  %s/\(<[^>]*>\).*$/\1/
  " remove values of attributes
  %s/='[^']*'//g
  %s/="[^"]*"//g
  " remove empty lines
  g/^\s*$/d
endfunction

" Strips tags from a buffer. The expression is non-greedy and catches tags that span multiple lines.
function! StripTags()
  %s/<\_.\{-1,\}>//g
  " remove empty lines
  g/^\s*$/d
endfunction

" Add new line after every element
function! XMLNewLines()
  %s/>/>\r/g
  " remove empty lines
  g/^\s*$/d
endfunction

" Highlights duplicated lines in given range
" from http://stackoverflow.com/a/1270689
function! HighlightRepeats() range
  let lineCounts = {}
  let lineNum = a:firstline
  while lineNum <= a:lastline
    let lineText = getline(lineNum)
    if lineText != ""
      let lineCounts[lineText] = (has_key(lineCounts, lineText) ? lineCounts[lineText] : 0) + 1
    endif
    let lineNum = lineNum + 1
  endwhile
  exe 'syn clear Repeat'
  for lineText in keys(lineCounts)
    if lineCounts[lineText] >= 2
      exe 'syn match Repeat "^' . escape(lineText, '".\^$*[]') . '$"'
    endif
  endfor
endfunction

" Toggles x and / characters in checkboxes
" The checkbox must be in shaped as (x)
" Only the first occurence on the line is taken into account
function! ToggleTodo()
  if getline('.') =~# "(x)"
    normal ma
    s/(x)/(\/)/
    normal `a
  else
    if getline('.') =~# "(/)"
      normal ma
      s/(\/)/(x)/
      normal `a
    endif
  endif
  normal j
endfunction

" Creates Perl like list definition from lines
" Assumes that lines form a separated paragraph
function! MakeListFromLines(...)
  if a:0 > 0
    execute "normal! vip$A".a:1."vip0I".a:1.""
    normal vip$A,vipJA$x0
  else
    normal vip$A,vipJA$x0
  endif
endfunction
function! MakeClearListFromLines(...)
  if a:0 > 0
    execute "normal! vip$A".a:1."vip0I".a:1.""
    normal vip$A,vipJA$x0
    s/[ \t]\+//g
    s/,/,\ /g
  else
    normal vip$A,vipJA$x0
    s/[ \t]\+//g
    s/,/,\ /g
  endif
endfunction

" Creates list of items on separated lines
" from Perl like list definition of strings
function! MakeLinesFromList()
  s/\s*//g
  s/,/\r/g
endfunction
function! MakeClearLinesFromList()
  s/['"();\ ]//g
  call MakeLinesFromList()
endfunction

" Closes all buffers except the active one
function! CloseAllBuffersButActive()
  let buf = bufnr('%')
  bufdo if bufnr('%') != buf | bdelete | endif
endfunction

" Rewrite the buffer with xpath matches only
" more in !xmlstar sel --help
function! Xpath(arg)
  echo a:arg
  execute '%!xmlstar sel -t -c "a:arg"'
endfunction

" Some vim commands output quite a lot of text and it would
" be nice to get the output in a more readable format.
" ( Source http://vimrcfu.com/snippet/171 )
" :Bufferize digraphs
" :Bufferize syntax
" :Bufferize highlight
" :Bufferize map
" :Bufferize let g:
function! s:Bufferize(cmd)
  let cmd = a:cmd
  redir => output
  silent exe cmd
  redir END
  new
  " setlocal nonumber
  call setline(1, split(output, "\n"))
  set nomodified
endfunction

function! s:Echo(cmd)
  redir @e
  silent exe "echo " . a:cmd
  redir END
  put e
endfunction

" ===== Toggle slashes =====
" http://vim.wikia.com/wiki/Change_between_backslash_and_forward_slash
function! ToggleSlash(independent) range
  let from = ''
  for lnum in range(a:firstline, a:lastline)
    let line = getline(lnum)
    let first = matchstr(line, '[/\\]')
    if !empty(first)
      if a:independent || empty(from)
        let from = first
      endif
      let opposite = (from == '/' ? '\' : '/')
      call setline(lnum, substitute(line, from, opposite, 'g'))
    endif
  endfor
endfunction
command! -bang -range ToggleSlash <line1>,<line2>call ToggleSlash(<bang>1)

" ===== Toogle options flag =====
function! ToggleFlag(option,flag)
  exec ('let lopt = &' . a:option)
  if lopt =~ (".*" . a:flag . ".*")
    exec ('set ' . a:option . '-=' . a:flag)
  else
    exec ('set ' . a:option . '+=' . a:flag)
  endif
endfunction

" Source http://stackoverflow.com/questions/12833189
function! JumpToCSS()
  let id_pos = searchpos("id", "nb", line('.'))[1]
  let class_pos = searchpos("class", "nb", line('.'))[1]

  if class_pos > 0 || id_pos > 0
    if class_pos < id_pos
      execute ":vimgrep '#".expand('<cword>')."' **/*.*ss"
    elseif class_pos > id_pos
      execute ":vimgrep '.".expand('<cword>')."' **/*.*ss"
    endif
  endif
endfunction

" Measure the time a given command takes to finish and store it in register t
" Use python to gain miliseconds precision
" Originally from:
" http://vim.wikia.com/wiki/Measure_time_taken_to_execute_a_command
function! HowLong( command )
python <<EOF
import vim
import time
start = time.clock()
vim.command("execute a:command")
end = time.clock()
duration = end - start
vim.command("let @t = string({0:.2f})".format(duration))
EOF
endfunction

" Prints number of rows, duration and connection details
" of the performed query (MySQL).
" - Called by dbext after query is finished
" - Clears the lines which are not parts of the result
" - Assumes -vv and -t options are set
" - Saves message in @r register
function! DBextPostResult(db_type, buf_nr)
  " Info from result
  let l:connection = getline(line('.'))
  let l:connection = substitute(l:connection, '\s\+', '\ ', 'g')
  let l:rowsline = getline(search('^\d\+ row\|^Empty\ set'))

  " Save original
  let @o = join(getline(1,'$'), "\n")

  " Result cleanup
  silent! %s/^--------------\_.*--------------$//ge
  silent! /mysql.*command\ line\ interface/d
  silent! /^Connection/d
  silent! /^Bye/d
  silent! /^\d\+ row/d
  silent! /^\s*$/d
  silent! %s//1/ge

  " Resize buffer
  let l:line_length = len(getline(line('.')))
  if l:line_length >= 130
    execute "wincmd J"
  else
    execute "wincmd L"
    execute "vertical resize 100"
  endif

  " Create message
  redraw
  let l:count = matchstr(l:rowsline, '\d\+\ze row')
  if l:count == ""
    let l:count = 0
  endif
  let l:rows = "rows"
  if 1 == l:count
    let l:rows = "row"
  endif
  let l:msg =  l:count." ".l:rows." returned in ".@t
  let l:msg .= " seconds (".l:connection.")"
  let @r = l:msg
  echom l:msg
endfunction

function! Expander()
  let line   = getline(".")
  let col    = col(".")
  let first  = line[col-2]
  let second = line[col-1]
  let third  = line[col]
  if first ==# ">"
    if second ==# "<" && third ==# "/"
      return "\<CR>\<Esc>O"
    else
      return "\<CR>"
    endif
  else
    return "\<CR>"
  endif
endfunction

" }}}
"  Behaviour {{{ ===============================================================

" ===== Script to save gvim window position =====
if has('gui_running')
  function! ScreenFilename()
    if has('amiga')
      return "s:.vimsize"
    elseif has('win32')
      return $HOME.'\_vimsize'
    else
      return $HOME.'/.vimsize'
    endif
  endfunction

  function! ScreenRestore()
    " Restore window size (columns and lines) and position
    " from values stored in vimsize file.
    " Must set font first so columns and lines are based on font size.
    let f = ScreenFilename()
    if has('gui_running') && g:screen_size_restore_pos && filereadable(f)
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      for line in readfile(f)
        let sizepos = split(line)
        if len(sizepos) == 5 && sizepos[0] == vim_instance
          silent! execute "set columns=".sizepos[1]." lines=".sizepos[2]
          silent! execute "winpos ".sizepos[3]." ".sizepos[4]
          return
        endif
      endfor
    endif
  endfunction

  function! ScreenSave()
    " Save window size and position.
    if has('gui_running') && g:screen_size_restore_pos
      let vim_instance = (g:screen_size_by_vim_instance==1?(v:servername):'GVIM')
      let data = vim_instance . ' ' . &columns . ' ' . &lines . ' ' .
            \ (getwinposx()<0?0:getwinposx()) . ' ' .
            \ (getwinposy()<0?0:getwinposy())
      let f = ScreenFilename()
      if filereadable(f)
        let lines = readfile(f)
        call filter(lines, "v:val !~ '^" . vim_instance . "\\>'")
        call add(lines, data)
      else
        let lines = [data]
      endif
      call writefile(lines, f)
    endif
  endfunction

  if !exists('g:screen_size_restore_pos')
    let g:screen_size_restore_pos = 1
  endif
  if !exists('g:screen_size_by_vim_instance')
    let g:screen_size_by_vim_instance = 1
  endif
  augroup vimgui
    autocmd!
    autocmd VimEnter * if g:screen_size_restore_pos == 1 | call ScreenRestore() | endif
    autocmd VimLeavePre * if g:screen_size_restore_pos == 1 | call ScreenSave() | endif
  augroup END
endif
" End of position saving script
