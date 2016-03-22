" ==============================================================================
"  .vimrc of Lukas Trumm {{{1
" ==============================================================================

" Source the _vimrc and _gvimrc file after saving it
augroup configuration
    autocmd!
    autocmd BufWritePost vimrc source $MYVIMRC
augroup END

" }}}
" ============================================================================
"  Plugins {{{1
" ============================================================================

" Automatic installation of Plug
if has('unix')
    if empty(glob('~/.vim/autoload/plug.vim'))
    silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
        \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
    autocmd VimEnter * PlugInstall | source $MYVIMRC
    endif
endif

call plug#begin()

Plug 'AndrewRadev/splitjoin.vim'
Plug 'Chiel92/vim-autoformat'
Plug 'KabbAmine/zeavim.vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'Raimondi/delimitMate'
Plug 'Yggdroot/indentLine' ",               { 'on': 'IndentLinesEnable' }
Plug 'airblade/vim-gitgutter' ",            { 'on': 'GitGutterToggle'   }
" Plug 'airblade/vim-rooter'
Plug 'bonsaiben/bootstrap-snippets' ",      { 'for': 'html'             }
Plug 'chrisbra/csv.vim',                    { 'for': 'csvx' }
Plug 'chrisbra/unicode.vim'
Plug 'coderifous/textobj-word-column.vim'
Plug 'dhruvasagar/vim-table-mode'
Plug 'drmikehenry/vim-fontsize'
Plug 'dzeban/vim-log-syntax' ",             { 'for': 'log'              }
Plug 'ervandew/supertab'
Plug 'garbas/vim-snipmate'
Plug 'godlygeek/tabular'
Plug 'gregsexton/gitv' ",                   { 'on': 'Gitv'              }
Plug 'groenewege/vim-less'
Plug 'hail2u/vim-css3-syntax'
Plug 'honza/vim-snippets'
" Plug 'itchyny/lightline.vim'
Plug 'janiczek/vim-latte'
Plug 'junegunn/goyo.vim'
Plug 'junegunn/vim-journal'
Plug 'justinmk/vim-gtfo'
Plug 'kana/vim-textobj-function'
Plug 'kana/vim-textobj-user'
Plug 'kien/ctrlp.vim'
Plug 'lttr/sql_iabbr.vim'
Plug 'majutsushi/tagbar' ",                 { 'on': 'TagbarToggle'      }
Plug 'mattn/emmet-vim'
Plug 'mbbill/undotree' ",                   { 'on': 'UndotreeToggle'    }
Plug 'michaeljsmith/vim-indent-object'
Plug 'moll/vim-bbye'
Plug 'othree/xml.vim'
Plug 'pangloss/vim-javascript'
Plug 'rking/ag.vim'
Plug 'salsifis/vim-transpose'
Plug 'scrooloose/nerdcommenter'
Plug 'scrooloose/nerdtree' ",               { 'on': 'NERDTreeToggle'    }
Plug 'scrooloose/syntastic'
Plug 'sheerun/vim-polyglot'
Plug 'sickill/vim-pasta'
Plug 'sjl/clam.vim'
Plug 'skammer/vim-css-color'
Plug 'terryma/vim-multiple-cursors'
Plug 'tommcdo/vim-exchange'
Plug 'tomtom/tlib_vim'
Plug 'tpope/vim-characterize'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-markdown'
Plug 'tpope/vim-repeat'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-unimpaired'
Plug 'triglav/vim-visual-increment'
Plug 'tyru/open-browser.vim'
Plug 'tyru/restart.vim'
Plug 'vim-scripts/Rename'
Plug 'vim-scripts/argtextobj.vim'
Plug 'vim-scripts/dbext.vim'
Plug 'vim-scripts/gnuplot.vim'
Plug 'vim-scripts/loremipsum'
Plug 'vim-scripts/matchit.zip'
Plug 'vim-scripts/visSum.vim'
Plug 'vim-voom/VOoM' ",                     { 'on': 'Voom'              }
Plug 'vobornik/vim-mql4'
Plug 'xolox/vim-misc'
Plug 'xolox/vim-shell'
Plug 'hdima/python-syntax'

call plug#end()

" }}}
" ==============================================================================
"  General settings {{{1
" ==============================================================================
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

" experimental
set noshelltemp  " Should avoid some cmd windows for external commands

" ===== Buffers =====
set hidden                     " Allow buffer switching without saving
set splitright                 " Puts new vsplit windows to the right of the current
set splitbelow                 " Puts new split windows to the bottom of the current

" ===== Directories ====== 
set backup                     " Make backups
if has('unix')
	set backupdir  =~/.vim/backups " List of directory names for backup files
	set directory  =~/.vim/backups " List of directory names for swap files
	set undodir    =~/.vim/undos   " List of directory names for undo files
else
	set backupdir  =~/vimfiles/backups " List of directory names for backup files
	set directory  =~/vimfiles/backups " List of directory names for swap files
	set undodir    =~/vimfiles/undos   " List of directory names for undo files
endif
set undofile                   " Automatically saves undo history to an undo file
set undolevels =1000           " Maximum number of changes that can be undone
set undoreload =10000          " Maximum number lines to save for undo on a buffer reload
set writebackup                " Make a backup before overwriting a file
set tags       =./tags;        " Find tags file in parent dirs (;) starting in current dir (./)

" ===== Folding =====
set foldlevel  =3              " Expand level 1 folds
set foldmethod =manual
set nofoldenable

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
" set noexpandtab              " Use <Tab>s
" set autoindent               " Copy indent from current line when starting a new line
" set copyindent               " Autoindent the new line
" set smarttab                 " Inserts or deletes blanks according to tab settings
" set smartindent              " Try to be smart when starting a new line in some conditions

" ===== Wrapping =====
set textwidth =0               " Maximum width of text that is being inserted (0 = no hard wrap)
set linebreak                  " Dont wrap words
if exists("&breakindent")
  set breakindent              " Soft wrapped lines will continue visually indented (since vim 7.4.x)
endif

" }}}
" ==============================================================================
"  Appearance {{{1
" ==============================================================================

"  ===== Language =====
" language us

" ===== Cursor =====
set guicursor+=a:blinkon0   " Disable blinking cursor in normal mode

" ===== Font =====
if has('unix')
  set guifont=Monospace\ 12
else
  set guifont=Consolas:h11 
endif

" ===== GUI adjustments =====
set guioptions-=b " Hide horizontal (bottom) scrollbar
set guioptions-=e " Text based tabs
set guioptions-=l " Hide left vertical scrollbar
set guioptions-=L 
set guioptions-=m " Remove menu bar
" set guioptions-=r
set guioptions-=R 
set guioptions-=T " Remove toolbar
set guitablabel=%f

" ===== Status line  =====
" Currently using Lightline plugin
" useful tips: http://stackoverflow.com/q/5375240
set noruler                                          " No useful info in ruler for me
set laststatus =2                                    " Always show statusline

" Left side
set statusline =
set statusline +=\ %<%f                              " tail of the filename
set statusline +=\ %m                                " modified flag
set statusline +=\ %r                                " read only flag
" insert current git branch name, 7 chars from commit in case of detached HEAD 
set statusline+=\ %{exists('g:loaded_fugitive')?fugitive#head(7):''}

" Separator
set statusline +=\ %=                                " left/right separator

" Right side
set statusline +=\ \|\ %{&ft}                        " filetype (neither %y nor %Y does fit)
set statusline +=\ \|\ %{&fenc}                      " file encoding
set statusline +=\ \|\ %{strpart(&ff,0,1)}           " file format
set statusline +=\ \|\ %l:%c                         " total lines and virtual column number
set statusline +=\ \|\ %P                            " percentage
set statusline +=\                                   " right margin

" ===== Syntax highlighting =====
syntax enable
set background =light
if !has("gui_running")
    set t_Co=256
endif
colorscheme solarized
set synmaxcol  =500             " Max column in which to search for syntax items (better performance)

" ===== Whitespace =====
set listchars=tab:»\ ,trail:•,extends:#,nbsp:.  " Highlight problematic whitespace

" ===== Fonts customization =====

" Search
" hi Search guifg=#e7dfc6 guibg=#073642
" hi IncSearch guifg=#e7dfc6 guibg=#073642
" Row numbers
hi LineNr guifg=#c2c0ba
hi LineNr ctermfg=251

" }}}
" ==============================================================================
"  Completion {{{1
" ==============================================================================

" function to call when Ctrl-X Ctrl-O pressed in Insert mode
set omnifunc=syntaxcomplete#Complete
" show menu when there is more then one item to complete
" only insert the longest common text of the matches.
set completeopt=menu,longest
" Make <Tab> select the currently selected choice, same like <cr>
" If not in completion mode, call snippets expanding function
imap <expr> <Tab> pumvisible() ? "\<c-y>" : "<Plug>snipMateNextOrTrigger"
inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<cr>"

set complete-=i

"...more under SuperTab plugin settings

" }}}
" ==============================================================================
"  Global shortcuts {{{1
" ==============================================================================

" ===== MapLeaders =====
" Set leader keys to ensure their assignment
" <Leader> for global shortcuts, <LocalLeader> for more specific and local usage
let mapleader = ","
let maplocalleader = "\<space>"

" ===== Bubble lines up and down =====
" tip from http://vimrcfu.com/snippet/110
nnoremap <A-j> :m .+1<CR>==
nnoremap <A-k> :m .-2<CR>==
inoremap <A-j> <Esc>:m .+1<CR>==gi
inoremap <A-k> <Esc>:m .-2<CR>==gi
vnoremap <A-j> :m '>+1<CR>gv=gv
" without `` at the end of mapping
vnoremap <A-k> :m '<-2<CR>gv=gv

" ===== Change indentation =====
nnoremap <A-h> <<
nnoremap <A-l> >>
vnoremap <A-h> <gv
vnoremap <A-l> >gv
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
nnoremap <C-v> "+p
" paste from insert mode
inoremap <C-v> <Esc>"+p
" paste over in visual mode
vnoremap <C-v> d"+gP
" Replace selection with yanked or deleted text
" TODO Does not work correctly at the end of a line
vnoremap s "_dgp
" Don't copy the contents of an overwritten selection
vnoremap p "_dgP

" ===== Exiting =====
" Quit buffer without closing the window (plugin Bbye)
nnoremap Q :Bdelete<cr>
" Quit window
nnoremap <leader>q :q<cr>
" <C-z> minimizes gvim on Windows, which I dont like
nnoremap <C-z> <Esc>

" ===== Headings =====
" Make commented heading from current line, using Commentary plugin (no 'noremap')
nmap <LocalLeader>+ O<esc>78i=<esc>gccjo<esc>78i=<esc>gcckgcc0a<space><esc>
" Make commented subheading from current line, using Commentary plugin (no 'noremap')
nmap <LocalLeader>= I<space><esc>A<space><esc>05i=<esc>$5a=<esc>gcc

" ===== Increment =====
nnoremap <silent> g<C-a> :<C-u>call Increment('next', v:count1)<CR>
nnoremap <silent> g<C-x> :<C-u>call Increment('prev', v:count1)<CR>

" ===== Mouse buttons =====
" Set right mouse button to do paste
nnoremap <RightMouse> "*p
inoremap <RightMouse> <c-r>*
cnoremap <RightMouse> <c-r>*

" ===== Opening =====
" Open current document in browser (save it before)
nnoremap <leader>o :w<CR>:OpenInVivaldi<CR>

" ===== Open configuration files =====
nnoremap <leader>V :split $MYVIMRC<CR>

" ===== Plugin toggles =====
nnoremap <leader>gg :GitGutterToggle<CR>
nnoremap <F2> :NERDTreeFind<CR>
nnoremap <F3> :NERDTreeToggle<CR>
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <leader>G :Goyo<CR>

" ===== Programming shortcuts =====
nnoremap <LocalLeader>; m`A;<esc>``

" ===== Saving buffer =====
" Use ctrl+s for saving, also in Insert mode (from mswin.vim) 
noremap  <C-s> :update<CR>
vnoremap <C-s> <C-C>:update<CR>
inoremap <C-s> <Esc>:update<CR>

" ===== Searching =====
" Visual search and Save search for later n. usage = multiple renaming
" Even more powerful with cgn = change next occurance, than 
nnoremap gr /\<<C-r><C-w>\><CR><C-o>:set hlsearch<CR>viwo
vnoremap gr y/<C-r>"<CR><C-o>:set hlsearch<CR>gvo
" Go substitute
nnoremap gs :%s//g<Left><Left>
vnoremap gs y:%s#\><C-r>\>"##g<Left><Left>
" Go substitute word
nnoremap gss :set hls<CR>/\<<C-r><C-w>\><CR>:%s/\<<C-r><C-w>\>//g<Left><Left>

" Selects the text that was entered during the last insert mode usage
nnoremap gV `[v`]

" ===== Strings =====
" Surround current word
nnoremap <LocalLeader>" m`viw<esc>a"<esc>hbi"<esc>lel``
nnoremap <LocalLeader>' m`viw<esc>a'<esc>hbi'<esc>lel``
" Toggle between single and double quotes
nnoremap g' m`:s#['"]#\={"'":'"','"':"'"}[submatch(0)]#g<CR>``
vnoremap g' m`:s#['"]#\={"'":'"','"':"'"}[submatch(0)]#g<CR>``
" Toggle between backslashes and forward slashes
noremap <silent> g/ :ToggleSlash<CR>

" ===== Windows and Buffers =====
" Set working dir to current file dir, only for current window
nnoremap <leader>. :lcd %:p:h<CR>:echo "CWD changed to ".expand('%:p:h')<CR>

" Open previous buffer
noremap <leader>v :vsplit<CR>:bp<CR>
noremap <leader>s :split<CR>:bp<CR>

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
" More convenient keys for start and end of line
nnoremap H 0
nnoremap L $

" ===== Moving in windows =====
" Cycling windows
nnoremap <Tab> <C-W>w
" Alt+LeftArrow to go back (also with side mouse button)
nnoremap <A-Left> ``
" Jump to left or right window
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
" Move screen 10 characters left or right in wrap mode
nnoremap gh 40zh
nnoremap gl 40zl

" ===== Wrap mode =====
" change wrap and set or unset bottom scroll bar
nnoremap <expr> <leader>w ':set wrap! go'.'-+'[&wrap]."=b\r"

" }}}
" ==============================================================================
"  Appearance shortcuts {{{1
" ==============================================================================

" ===== Font size =====
nnoremap <S-F12> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) - 1)', '')<CR>
nnoremap <F12> :let &guifont = substitute(&guifont, ':h\(\d\+\)', '\=":h" . (submatch(1) + 1)', '')<CR>

" ===== Highlighting =====
" Show highlight groups under cursor
noremap <F10> :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . "> fgcolor<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"fg") . ">"<CR>

" }}}
" ==============================================================================
"  General commands {{{1
" ==============================================================================

" ===== Bufferize =====
" Print output of MORE viewer into buffer
command! -nargs=* -complete=command Bufferize call s:Bufferize(<q-args>)

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
command! Extract :call Extract()

" ===== Lists =====
" Creates Perl style list definition from paragraph of items on lines
command! -nargs=* ToList call MakeListFromLines(<q-args>)
" Reverse from the list to lines
command! ToLines :call MakeLinesFromList()
command! ToLinesClear :call MakeClearLinesFromList()

command! FoldLines normal :1,g/^/''+m.|-j!<cr>

" ===== Open buffer in =====
" Open current document in browser (save it before)
command! OpenInFirefox :call OpenCurrentDocumentInBrowser('firefox')
command! OpenInChrome :call OpenCurrentDocumentInBrowser('chrome')
command! OpenInVivaldi :call OpenCurrentDocumentInBrowser('vivaldi')

" ===== Repeated lines =====
command! -range=% HighlightRepeats <line1>,<line2>call HighlightRepeats()
command! UnHighlight syn clear Repeat

" ===== Strips tags from buffer =====
command! StripTags call StripTags()

" ===== Strip trailing whitespaces =====
command! StripTrailingWhitespace :call StripTrailingWhitespace()

" ===== XML and Xpath =====
" Rewrite the buffer with xpath matches only
command! -nargs=1 Xpath :call Xpath(<args>)
command! XMLNewLines call XMLNewLines()
command! XMLSimplify :silent call XMLSimplify()

" }}}
" ==============================================================================
"  Filetype specific commands {{{1
" ==============================================================================

" Common shortcuts
" <leader>c = compile
" <leader>r = run
" <leader>t = test
" <leader>h = help
" <leader>k = check style
" <leader>f = format

" ===== Misc filetypes =====

augroup global
    autocmd!
    " Cursor on last editing place in every opened file
    autocmd BufReadPost * normal `"     
augroup END

augroup syntax-sugar
    autocmd!
    " Make it so that a curly brace automatically inserts an indented line
    autocmd FileType javascript,css,perl,php,java inoremap {<CR> {<CR>}<Esc>O
augroup END

" ===== Bash =====
augroup bash
    autocmd!
    autocmd BufRead,BufNewFile *.bash set filetype=sh
augroup END

" ===== Dosbatch =====
augroup dosbatch
    autocmd!
	autocmd FileType dosbatch set formatoptions -=o
    " Run dosbatch bat file
    autocmd FileType dosbatch nnoremap <buffer> <leader>r :w<CR>:Clam %:p<CR>gg<C-w>w
augroup END

" ===== HTML =====
augroup html
    autocmd!
    autocmd FileType html setlocal dictionary+=$HOME/vimfiles/bundle/bootstrap-snippets/dictionary
    autocmd FileType html noremap <leader>f :!tidy -xml -q -i -w 0 --show-errors 0
                \ -config ~/vimfiles/ftplugin/tidyrc_html.txt <CR>
augroup END

" ===== Gnuplot =====
augroup gnuplot
    autocmd!
    " Compile gnuplot graph
    autocmd FileType gnuplot nnoremap <buffer> <leader>c :w<CR>:silent !cmd /c gnuplot -p %<CR>
    autocmd FileType gnuplot setlocal commentstring=#\ %s
    " Set filetype automatically
    autocmd BufRead,BufNewFile *.plt set filetype=gnuplot
augroup END

" ===== Java =====
augroup java
    autocmd!
    autocmd Filetype java nnoremap <buffer> <leader>c :w<CR>:!javac %<CR>
    autocmd Filetype java nnoremap <buffer> <leader>r :Clam java -cp . %:r<CR>
    autocmd FileType java set tags=tags;$SYNC_DIR/dev/sources/java/java-jdk8-src/tags
    " autocmd FileType java set tags=tags;
augroup END

" ===== JavaScript =====
augroup javascript
    autocmd!
    autocmd Filetype javascript nnoremap <buffer> <CR> :w<CR>
	autocmd Filetype javascript nnoremap <leader>f :Autoformat<CR>
augroup END

" ===== Json =====
augroup json
	autocmd!
	autocmd Filetype json nnoremap <leader>f :%!python -m json.tool<CR>
augroup END

" ===== Jira =====
augroup jira
    autocmd!
    " Set filetype automatically
    autocmd BufRead,BufNewFile *.jira setlocal filetype=jira
augroup END

" Create Jira style aligned table from tab separated items of one paragraph
" First line will have double | (pipe) characters as separators
command! JiraTable normal
	\ vip:s/\t/|/g<CR>
	\ vip:s/^/|\ /<CR>
	\ vip:s/$/\ |/<CR>
	\ vip:Tabularize/|<CR>
	\ {j:s/|\ \?/||/g<CR>

" ===== Markdown =====
augroup markdown
    autocmd!
    autocmd FileType modula2  setlocal ft         =markdown
    autocmd FileType markdown setlocal textwidth  =80
    autocmd FileType markdown setlocal autoindent
    " autocmd FileType markdown noremap <buffer> <Space> :silent call ToggleTodo()<CR>

    autocmd FileType markdown command! Outline :Voom markdown

    " Underline heading
    autocmd FileType markdown nnoremap <LocalLeader>h m`^y$o<Esc>pVr=``
    " Prefix # heading
    autocmd FileType markdown nnoremap <LocalLeader>0 m`:s/^\(#*\)\ \?//<CR>``
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
    autocmd FileType markdown nnoremap <LocalLeader>> vip<c-q>0I><space><Esc>
    autocmd FileType markdown vnoremap <LocalLeader>> <c-q>0I><space><Esc>
    " unordered list
    autocmd FileType markdown nnoremap <LocalLeader>u vip:s/^\(\s*\)/\1- /<cr>
    autocmd FileType markdown vnoremap <LocalLeader>u :s/^.\?/\U&/

    " Save mkd file
    autocmd FileType markdown nnoremap <LocalLeader>s :1y<CR> :w <C-r>"<BS>.md
    " Link from address - last segment to be the text
    autocmd FileType markdown nnoremap <LocalLeader>l :s/\v((https?\|www).*\/)([^\/ \t)]+)(\/?)/[\3](&)/<CR>vi[
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
	\ yypVr=o

" Creates Markdown style web links
" Replaces any row and following row with URL with Markdown syntax for links
command! MDlinks :%s/\(.*\)\n\(\(http\|www\).*\)/[\1](\2)/<CR>

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

" ===== Python =====
augroup python
    autocmd!
    autocmd FileType python let python_highlight_all =1
    autocmd FileType python setlocal textwidth =79
	autocmd FileType python setlocal tabstop   =4

    if has('win32')
        autocmd FileType python noremap <buffer> <leader>h :!python -m pydoc <c-r><c-w><CR>
    endif
    if has('unix')
        autocmd FileType python noremap <buffer> <leader>h :!pydoc <c-r><c-w><CR>
    endif
    autocmd FileType python noremap <buffer> <leader>R :w<CR>:silent !python %<CR>
    autocmd FileType python noremap <buffer> <leader>r :w<CR>:Clam python %<CR><C-w>h
augroup END

" ===== Shell =====
augroup sh
    autocmd!
    " Run current row as command
    autocmd FileType sh nnoremap <c-cr> ^y$:!<c-r>"<cr>
augroup END

" ===== SQL =====
augroup sql
    autocmd!
	" Set filetype automatically
	autocmd BufRead,BufNewFile *.ddl setlocal filetype=sql

    " SQL comments
    autocmd FileType sql setlocal commentstring=--\ %s

    autocmd Filetype sql let g:dbext_default_window_use_horiz = 0  " Use vertical split
    autocmd Filetype sql let g:dbext_default_window_width = 120
	autocmd Filetype sql let g:dbext_default_always_prompt_for_variables = -1

    autocmd FileType sql vnoremap <c-cr> :DBExecVisualSQL<cr>
    autocmd FileType sql nnoremap <c-cr> :DBExecSQLUnderCursor<cr>
	autocmd FileType sql nnoremap <LocalLeader>r :echo g:dbext_rows_affected - 5<CR>

    " Spaces works better then tabs for MySQL
    autocmd Filetype sql setlocal expandtab
    " Upper case
    autocmd Filetype sql noremap <LocalLeader>u :s/\<update\>\\|\<select\>\\|\<delete\>\\|\<insert\>\\|\<from\>\\|\<where\>\\|\<join\>\\|\< left join\>\\|\<inner join\>\\|\<on\>\\|\<group by\>\\|\<order by\>\\|\<and\>\\|\<or\>\\|\<as\>/\U&/ge<cr><esc>
    " New lines before and after keywords
    autocmd Filetype sql noremap <LocalLeader>f :s/\(\(\ \{4}\)*\)\(\<update\>\\|\<select\>\\|\<from\>\\|\<where\>\\|\<group by\>\\|\<order by\>\)\ /\r&\r\1\ \ \ \ /ge<cr>:s/\<join\>/\r\ \ \ \ &/g<cr>
augroup END

" ===== VBA =====
augroup vba
    autocmd!
    " Do not count ' as quotes
    autocmd FileType vb let b:delimitMate_quotes = "\" `"
augroup END

" Opens browser with Microsoft MSDN search for current key word
command! MSDN :silent :OpenBrowser 
            \http://social.msdn.microsoft.com/Search/en-US?query=
            \<c-r><c-w><CR>

" ===== Vim =====
augroup vimfile
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" ===== XML (and HTML) =====
" previous tag on same indentation level
nnoremap <C-K> ?^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>nww
" next tag on same indentation level
nnoremap <C-J> /^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>ww
" Up one level = go to parent tag
nnoremap <leader>hu vat`<<Esc>
" Expand content of a tag
nnoremap <leader>he vitdi<CR><Esc>O<C-r>"<Esc>
vnoremap <leader>he di<CR><Esc>O<C-r>"
" Shrink content of a tag
nnoremap <leader>hs kJxJxh
" Move tag with descendants DOWN
nnoremap <A-J> vatVd/^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>wwPvatV
vnoremap <A-J> d/^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>wwPvatV
" Move tag with descendants UP
nnoremap <A-K> vatVd?^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>nwwPvatV
vnoremap <A-K> d?^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>nwwPvatV

augroup xml
    autocmd!
    autocmd FileType xml nnoremap <leader>f :%!xmlstar fo -s 4<CR>
    autocmd FileType xml vnoremap <leader>f :!xmlstar fo -s 4<CR>
    " check if XML is wellformed
    command! Wellformed :!xmllint --noout %<CR>
augroup END

" }}}
" ==============================================================================
"  Plugin settings {{{1
" ==============================================================================

" ===== Ag =====
let g:ag_prg="ag --vimgrep --smart-case"
let g:ag_highlight=1

" ===== Autoformat =====
" sql - Indent String is 4 space and enable Trailing Commas
let g:formatdef_my_sql = 'sqlformatter /is:"    " /tc /uk /sk-'
let g:formatters_sql = ['my_sql']

" ===== CtrlP =====
" Set ctrl+p for normal fuzzy file opening
nnoremap <c-p> :CtrlP<cr>
" Set ctrl+h for most recently used files ('h'istory)
nnoremap <c-h> :CtrlPMRUFiles<cr>
let g:ctrlp_custom_ignore = {
    \ 'dir':  '\v[\/](\.(git|hg|svn)|\_site|target)$',
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

" ===== DelimitMate =====
let g:delimitMate_expand_cr    = 2  " Expand to new line after <cr>
let g:delimitMate_expand_space = 1  " Expand the <space> on both sides
" let g:delimitMate_autoclose  = 0  " Do not add closing delimeter automatically
" let g:delimitMate_offByDefault = 1  " Turn off by default
let delimitMate_excluded_ft = "markdown,txt,sh"
" Run :DelimitMateSwitch to turn on

" ===== Emmet =====
let g:user_emmet_leader_key = '<c-y>'
let g:emmet_html5           = 1

" ===== Fugitive =====
augroup fugitive
    autocmd!
	" delete w fugitive buffer from buffer list when no longer visible
    autocmd BufReadPost fugitive://* setlocal bufhidden=delete

	nnoremap <Leader>ga :Git add %:p<CR><CR>
	nnoremap <Leader>gs :Gstatus<CR>
	nnoremap <Leader>gc :Gcommit -v -q<CR>
	nnoremap <Leader>gt :Gcommit -v -q %:p<CR>
	nnoremap <Leader>gd :Gdiff<CR>
	nnoremap <Leader>gds :Git! diff --staged
	nnoremap <Leader>ge :Gedit<CR>
	nnoremap <Leader>gr :Gread<CR>
	nnoremap <Leader>gw :Gwrite<CR><CR>
	nnoremap <Leader>gl :silent! Glog<CR>:bot copen<CR>
	nnoremap <Leader>gp :Ggrep<Space>
	nnoremap <Leader>gm :Gmove<Space>
	nnoremap <Leader>gb :Git branch<Space>
	nnoremap <Leader>go :Git checkout<Space>
	nnoremap <Leader>gps :Dispatch! git push<CR>
	nnoremap <Leader>gpl :Dispatch! git pull<CR>
augroup END

" ===== GitGutter =====
let g:gitgutter_enabled = 0
let g:gitgutter_signs = 1
nmap [g <Plug>GitGutterPrevHunk
nmap ]g <Plug>GitGutterNextHunk
nmap <Leader>ggs <Plug>GitGutterStageHunk
nmap <Leader>ggr <Plug>GitGutterRevertHunk

" ===== Goyo =====
let g:goyo_width=100 "(default: 80)
let g:goyo_margin_top=2 " (default: 4)
let g:goyo_margin_bottom=2 " (default: 4)

" ===== IndentLine =====
let g:indentLine_enabled = 0

" " ===== Lightline =====
" let g:lightline = {
"     \ 'colorscheme': 'solarized',
"     \ 'active': {
"     \   'left': [ [ 'paste' ],
"     \             [ 'readonly', 'filename', 'modified' ] ],
"     \   'right': [ [ 'fugitive' ],
"     \              [ '' ],
"     \              [ '', 'filetype', 'fileencoding', 'fileformat', 'lineinfo', 'percentage' ] ]
"     \ },
"     \ 'inactive': {
"     \   'left': [ [ 'filename', 'modified' ] ],
" 	\   'right': [ [ 'fugitive' ],
" 	\              [ '' ],
" 	\              [ '', 'filetype', 'fileencoding', 'fileformat', 'lineinfo', 'percentage' ] ]
"     \ },
"     \ 'component': {
"     \   'fugitive': '%{exists("*fugitive#head")?fugitive#head():""}',
"     \   'fileformat': '%{toupper(strpart(&ff,0,1))}',
"     \   'lineinfo': '%l:%c',
" 	\   'percentage': '%P'
"     \ },
"     \ 'component_visible_condition': {
"     \   'fugitive': '(exists("*fugitive#head") && ""!=fugitive#head())'
"     \ }
"     \ }

" ===== LogViewer =====
let g:LogViewer_Filetypes = 'log' 

" ===== Markdown =====
let g:markdown_fenced_languages = ['bat=dosbatch', 'css', 'erb=eruby', 'javascript', 'js=javascript', 'json=javascript', 'ruby', 'sass', 'xml', 'java', 'sql', 'sh']

" ===== Multiple cursors =====
nnoremap <c-s-N> yiwvip:MultipleCursorsFind <c-r>"<CR>

" ===== NERDTree =====
let NERDTreeDirArrows=1

" ===== Pathogen plugin =====
" execute pathogen#infect()

" ===== PIV (PHP integration for VIM) =====
let g:DisableAutoPHPFolding = 1

" ===== Restart =====
let g:restart_sessionoptions = "restartsession"

" ===== SuperTab =====
let g:SuperTabMappingForward = '<c-space>'
let g:SuperTabMappingBackward = '<s-c-space>'
let g:SuperTabDefaultCompletionType = '<c-n>'
let g:SuperTabDefaultCompletionType = '<c-x><c-o>'
let g:SuperTabLongestHighlight = 0
" au FileType css let g:SuperTabDefaultCompletionType = '<c-x><c-o>'
" Probably slowing down
" autocmd FileType *
"       \ if &omnifunc != '' |
"       \     call SuperTabChain(&omnifunc, '<c-p>') |
"       \ endif

" ===== Syntastic =====
let g:syntastic_mode_map = {
    \ "mode": "passive",
    \ "active_filetypes": [],
    \ "passive_filetypes": [] }

" ===== Table Mode =====
let g:table_mode_corner     = "|"
let g:table_mode_align_char = ":"

" ===== Vim-markdown =====
let g:vim_markdown_folding_disabled=1

" ===== Voom =====
let g:voom_tree_placement = "right"
command! Outline :Voom

" ===== Xml.vim =====
let xml_tag_completion_map = "<c-l>"
" let g:xml_warn_on_duplicate_mapping = 1
" let xml_no_html = 1

" ===== Zeavim - Zeal integration =====
let g:zv_zeal_directory = "C:\\Program Files (x86)\\zeal\\zeal.exe"

" }}}
" ==============================================================================
"  Functions {{{1
" ==============================================================================

" Sessions from http://stackoverflow.com/a/10525050
set sessionoptions-=options  " Don't save options
function! SaveSession()
    execute 'mksession! ~/vimsession'
    echo 'Session saved.'
endfunction
function! RestoreSession()
    " if filereadable('~/vimsession')
        execute 'so ~/vimsession' 
        if bufexists(1)
            for l in range(1, bufnr('$'))
                if bufwinnr(l) == -1
                    exec 'sbuffer ' . l
                endif
            endfor
        endif
    " else
    "     echo 'Error: File with session not readable.'
    " endif
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
    s/<\_.\{-1,\}>//g
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

" Creates list of items on separated lines
" from Perl like list definition of strings
function! MakeLinesFromList()
    s/^\s*//
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

" Extract the matches of last search from current buffer
function! Extract()
    v//d
    execute "normal! :%s/.\\{-}\\(" . @/ . "\\).*/\\1/g<cr>"
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

" Increments the current digit instead of whole number
function! Increment(dir, count)
    " No number on the current line
    if !search('\d', 'c', getline('.'))
        return
    endif

    " Store cursor position
    let l:save_pos = getpos('.')

    " Add spaces around the number
    s/\%#\d/ \0 /
    call setpos('.', l:save_pos)
    normal! l

    " Increment or decrement the number
    if a:dir == 'prev'
        execute "normal! " . repeat("\<C-x>", a:count)
    else
        execute "normal! " . repeat("\<C-a>", a:count)
    endif

    " Remove the spaces
    s/\v (\d{-})%#(\d) /\1\2/

    " Restore cursor position
    call setpos('.', l:save_pos)
endfun

" ===== Script to save gvim window position =====
if has("gui_running")
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
    if has("gui_running") && g:screen_size_restore_pos && filereadable(f)
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
    if has("gui_running") && g:screen_size_restore_pos
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

