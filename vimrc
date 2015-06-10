" ==============================================================================
"  .vimrc of Lukas Trumm {{{1
" ==============================================================================

" Source the _vimrc and _gvimrc file after saving it
augroup configuration
    autocmd!
    autocmd BufWritePost _vimrc source $MYVIMRC
    autocmd BufWritePost _gvimrc source $MYGVIMRC
augroup END

" }}}
" ============================================================================
"  Plugins {{{1
" ============================================================================

set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

Plugin 'AndrewRadev/splitjoin.vim'
Plugin 'KabbAmine/zeavim.vim'
Plugin 'MarcWeber/vim-addon-mw-utils'
Plugin 'Raimondi/delimitMate'
Plugin 'Yggdroot/indentLine' ",               { 'on': 'IndentLinesEnable' }
Plugin 'airblade/vim-gitgutter' ",            { 'on': 'GitGutterToggle'   }
Plugin 'bonsaiben/bootstrap-snippets' ",      { 'for': 'html'             }
Plugin 'chrisbra/csv.vim' ",                  { 'for': 'csv'              }
Plugin 'chrisbra/unicode.vim'
Plugin 'coderifous/textobj-word-column.vim'
Plugin 'drmikehenry/vim-fontsize'
Plugin 'dzeban/vim-log-syntax' ",             { 'for': 'log'              }
Plugin 'ervandew/supertab'
Plugin 'garbas/vim-snipmate'
Plugin 'godlygeek/tabular'
Plugin 'gregsexton/gitv' ",                   { 'on': 'Gitv'              }
Plugin 'groenewege/vim-less'
Plugin 'hail2u/vim-css3-syntax'
Plugin 'honza/vim-snippets'
Plugin 'janiczek/vim-latte'
Plugin 'junegunn/goyo.vim'
Plugin 'junegunn/vim-journal'
Plugin 'justinmk/vim-gtfo'
Plugin 'kana/vim-textobj-entire'
Plugin 'kana/vim-textobj-function'
Plugin 'kana/vim-textobj-user'
Plugin 'kien/ctrlp.vim'
Plugin 'majutsushi/tagbar' ",                 { 'on': 'TagbarToggle'      }
Plugin 'mattn/emmet-vim'
Plugin 'mbbill/undotree' ",                   { 'on': 'UndotreeToggle'    }
Plugin 'michaeljsmith/vim-indent-object'
Plugin 'moll/vim-bbye'
Plugin 'neilagabriel/vim-geeknote'
Plugin 'othree/xml.vim'
Plugin 'pangloss/vim-javascript'
Plugin 'rking/ag.vim'
Plugin 'salsifis/vim-transpose'
Plugin 'scrooloose/nerdcommenter'
Plugin 'scrooloose/nerdtree' ",               { 'on': 'NERDTreeToggle'    }
Plugin 'sheerun/vim-polyglot'
Plugin 'sickill/vim-pasta'
Plugin 'sjl/clam.vim'
Plugin 'skammer/vim-css-color'
Plugin 'terryma/vim-multiple-cursors'
Plugin 'tommcdo/vim-exchange'
Plugin 'tomtom/tlib_vim'
Plugin 'tpope/vim-characterize'
Plugin 'tpope/vim-commentary'
Plugin 'tpope/vim-fugitive'
Plugin 'tpope/vim-markdown'
Plugin 'tpope/vim-repeat'
Plugin 'tpope/vim-sleuth'
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-unimpaired'
Plugin 'triglav/vim-visual-increment'
Plugin 'tyru/open-browser.vim'
Plugin 'tyru/restart.vim'
Plugin 'vim-scripts/Rename'
Plugin 'vim-scripts/gnuplot.vim'
Plugin 'vim-scripts/loremipsum'
Plugin 'vim-voom/VOoM' ",                     { 'on': 'Voom'              }
Plugin 'vobornik/vim-mql4'
Plugin 'xolox/vim-misc'
Plugin 'xolox/vim-shell'

call vundle#end()
filetype plugin indent on

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

" ===== Buffers =====
set hidden                     " Allow buffer switching without saving
set splitright                 " Puts new vsplit windows to the right of the current
set splitbelow                 " Puts new split windows to the bottom of the current

" ===== Directories ====== 
set backup                     " Make backups
set backupdir  =~/.vimbackup   " List of directory names for backup files
set directory  =~/.vimbackup   " List of directory names for swap files
set undodir    =~/.vimundos    " List of directory names for undo files
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
" set smartindent

" ===== Wrapping =====
set textwidth     =0           " Maximum width of text that is being inserted (0 = no hard wrap)
set linebreak                  " Dont wrap words
if exists("&breakindent")
  set breakindent                " Soft wrapped lines will continue visually indented (since vim 7.4.xxx)
endif

" }}}
" ==============================================================================
"  Appearance {{{1
" ==============================================================================

" ===== Cursor =====
set guicursor+=a:blinkon0   " Disable blinking cursor in normal mode

" ===== Font =====
if has('unix')
  set guifont=Monospace
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
" useful tips: http://stackoverflow.com/q/5375240
set noruler                                      " No useful info in ruler for me
set laststatus =2                                " Always show statusline
" Left side
set statusline =
set statusline +=\ %<%f                          " tail of the filename
set statusline +=\ %m                            " modified flag
set statusline +=\ %r                            " read only flag
" set statusline+=\ [%{getcwd()}]                  " Current dir
set statusline +=\ %=                            " left/right separator
" Right side
if exists("*fugitive#statusline")
	set statusline +=\ %{fugitive#statusline()}
endif
set statusline +=\ \|\ %{&ft}                        " filetype (neither %y nor %Y does fit)
set statusline +=\ \|\ %{strlen(&fenc)?&fenc:'none'} " file encoding
set statusline +=\ \|\ %{toupper(strpart(&ff,0,1))}  " file format
set statusline +=\ \|\ %l-%c                         " total lines and virtual column number
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
" TODO this is not a systematic approach

" Hide non text lines
hi NonText guifg=#c2c0ba        
" Markdown
hi Title guifg=#586e75
hi htmlBold gui=bold guifg=#839496
hi mkdIndentCode guifg=#b58900
hi mkdCode guifg=#b58900
hi mkdURL guifg=#839496
hi mkdID guifg=#b58900
" Search
hi Search guifg=#e7dfc6 guibg=#073642
hi IncSearch guifg=#e7dfc6 guibg=#073642
" JavaScript
hi javaScriptFuncExp gui=none guifg=#b58900
" Error messages
hi! ErrorMsg guibg=#cb4b16 guifg=#fdf6e3
" Fold column same like background
hi FoldColumn guibg=#fdf6e3
" Java
hi! link javaDocTags Comment
hi! link javaCommentTitle Comment
" HTML
hi htmlTitle gui=none guifg=#586e75
hi htmlH1 gui=none
" Row numbers
hi LineNr guifg=#c2c0ba

" }}}
" ==============================================================================
"  Completion {{{1
" ==============================================================================

" function to call when Ctrl-X Ctrl-O pressed in Insert mode
set omnifunc=syntaxcomplete#Complete
" show menu when there is more then one item to complete
" only insert the longest common text of the matches.
set completeopt=menu,longest
" Include defined dictionaries into completion
set complete+=k
" Make <Tab> select the currently selected choice, same like <cr>
" If not in completion mode, call snippets expanding function
imap <expr> <Tab> pumvisible() ? "\<c-y>" : "<Plug>snipMateNextOrTrigger"
inoremap <expr> <cr> pumvisible() ? "\<c-y>" : "\<cr>"

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

" ===== Boxes =====
" Create box around current line, text centered, text width 78
" http://boxes.thomasjensen.com/
nnoremap <leader>bb V:!boxes -a c -s 78<CR>}o<Esc>o<Esc>
vnoremap <leader>bb :!boxes -a c -s 78<CR>}o<Esc>o<Esc>
nnoremap <leader>br V:!boxes -r<CR>
vnoremap <leader>br :!boxes -r<CR>
nnoremap <leader>bl V:!boxes -a c -s 78 -d c-cmt<CR>f<space>v/[^ ]<CR>hhhr*w/\ \ <CR>llvt*r*o<Esc>
vnoremap <leader>bl :!boxes -a c -s 78 -d c-cmt<CR>f<space>v/[^ ]<CR>hhhr*w/\ \ <CR>llvt*r*o<Esc>

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

" ===== Code styling, beautifiers =====
" Tidy html and xml
noremap <leader>ht :!tidy -xml -q -i -w 0 --show-errors 0
            \ -config ~/vimfiles/ftplugin/tidyrc_html.txt <CR>
noremap <leader>hw :!tidy -xml -q -i -w 80 --show-errors 0
            \ -config ~/vimfiles/ftplugin/tidyrc_html.txt <CR>
nnoremap <leader>xf :%!xmlstar fo<CR>
vnoremap <leader>xf :!xmlstar fo<CR>
" check if XML is wellformed
nnoremap <leader>xw :!xmllint --noout %<CR>

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
vnoremap s "_dgP
" Don't copy the contents of an overwritten selection
vnoremap p "_dgP

" ===== Directories =====
" Set working dir to current file dir, only for current window
nnoremap <leader>. :lcd %:p:h<CR>:echo "CWD changed to ".expand('%:p:h')<CR>

" ===== Exiting =====
" Quit buffer without closing the window (plugin Bbye)
nnoremap Q :Bdelete<cr>
" Quit window
nnoremap <leader>q :q<cr>

" ===== Headings =====
" Make commented heading from current line, using Commentary plugin (no 'noremap')
nmap <LocalLeader>+ O<esc>78i=<esc>gccjo<esc>78i=<esc>gcckgcc0a<space><esc>
" Make commented subheading from current line, using Commentary plugin (no 'noremap')
nmap <LocalLeader>= I<space><esc>A<space><esc>05i=<esc>$5a=<esc>gcc

" ===== Mouse buttons =====
" Set right mouse button to do paste
nnoremap <RightMouse> "*p
cnoremap <RightMouse> "*p

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
nnoremap <S-Tab> <C-W>W
" Alt+LeftArrow to go back (also with side mouse button)
nnoremap <A-Left> ``
" Jump to left or right window
nnoremap <C-l> <C-w>l
nnoremap <C-h> <C-w>h
" Move screen
nnoremap <C-Up> <C-y>
nnoremap <C-Down> <C-e>
nnoremap <C-Left> zh
nnoremap <C-Right> zl

" ===== Custom text objects =====
onoremap e :<c-u>normal! mzggVG<cr>`z

" ===== Opening =====
" Open current document in browser (save it before)
nnoremap <leader>o :w<CR>:OpenInChrome<CR>
" Translation of a word at current cursor position
" It opens browser with google translater in it using open-browser plugin
nnoremap <leader>tr :silent :OpenBrowser
            \ http://translate.google.com/?sl=en&tl=cs&js=n&prev=_t&hl=cs&ie=UTF-8&eotf=1&text=
            \<c-r><c-w><CR
vnoremap <leader>tr :silent y:OpenBrowser
            \ http://translate.google.com/?sl=en&tl=cs&js=n&prev=_t&hl=cs&ie=UTF-8&eotf=1&text=
            \<c-r>"<CR>gv
nnoremap <leader>gu yi':OpenBrowser https://github.com/<c-r>"<cr>

" Edit another file in the same directory as the current file
noremap <leader>e :e <C-R>=escape(expand("%:p:h"),' ') . '/'<CR>
noremap <leader>s :split <C-R>=escape(expand("%:p:h"), ' ') . '/'<CR>
noremap <leader>v :vnew <C-R>=escape(expand("%:p:h"), ' ') . '/'<CR>

" ===== Open configuration files =====
nnoremap <localleader>v :split $MYVIMRC<CR>

" ===== Plugin toggles =====
nnoremap <leader>g :GitGutterToggle<CR>
nnoremap <leader>n :NERDTreeToggle<CR>
nnoremap <leader>nf :NERDTreeFind<CR>
nnoremap <silent> <F2> :NERDTreeFind<CR>
noremap <F3> :NERDTreeToggle<CR>
nnoremap <leader>u :UndotreeToggle<CR>
nnoremap <Leader>G :Goyo<CR>

" ===== Programming shortcuts =====
nnoremap <LocalLeader>; m`A;<esc>``

" ===== Saving buffer =====
" Use ctrl+s for saving, also in Insert mode (from mswin.vim) 
noremap  <C-s> :update<CR>
vnoremap <C-s> <C-C>:update<CR>
inoremap <C-s> <Esc>:update<CR>

" ===== Searching =====
" Visual search and Save search for later n. usage = multiple renaming
nnoremap gr /<C-r><C-w><CR><C-o>:set hlsearch<CR>
vnoremap gr y/<C-r>"<CR><C-o>:set hlsearch<CR>
" Map <Leader>ff to display all lines with keyword under cursor and ask which
" one to jump to
nnoremap <leader>ff [I:let nr = input("Which one: ")<Bar>exe "normal " . nr ."[\t"<CR>
" Selects the text that was entered during the last insert mode usage
nnoremap gV `[v`]
" Go Substitute
nnoremap gs :%s//g<Left><Left>

" ===== Strings =====
" Surround current word
nnoremap <LocalLeader>" m`viw<esc>a"<esc>hbi"<esc>lel``
nnoremap <LocalLeader>' m`viw<esc>a'<esc>hbi'<esc>lel``
" Toggle between single and double quotes
nnoremap g' m`:s/['"]/\="'\""[submatch(0)!='"']/g<CR>``
vnoremap g' m`:s/['"]/\="'\""[submatch(0)!='"']/g<CR>``

" ===== Tab =====
" ----------------------------------------------------------------------------
" <tab> / <s-tab> / <c-v><tab> | super-duper-tab
" ----------------------------------------------------------------------------
" function! s:can_complete(func, prefix)
"   if empty(a:func) || call(a:func, [1, '']) < 0
"     return 0
"   endif
"   let result = call(a:func, [0, matchstr(a:prefix, '\k\+$')])
"   return !empty(type(result) == type([]) ? result : result.words)
" endfunction

" function! s:super_duper_tab(k, o)
"   if pumvisible()
"     return a:k
"   endif
"   let line = getline('.')
"   let col = col('.') - 2
"   if empty(line) || line[col] !~ '\k\|[/~.]' || line[col + 1] =~ '\k'
"     return a:o
"   endif

"   let prefix = expand(matchstr(line[0:col], '\S*$'))
"   if prefix =~ '^[~/.]'
"     return "\<c-x>\<c-f>"
"   endif
"   if s:can_complete(&omnifunc, prefix)
"     return "\<c-x>\<c-o>"
"   endif
"   if s:can_complete(&completefunc, prefix)
"     return "\<c-x>\<c-u>"
"   endif
"   return a:k
" endfunction

" inoremap <expr> <tab>   <SID>super_duper_tab("\<c-n>", "\<tab>")
" inoremap <expr> <s-tab> <SID>super_duper_tab("\<c-p>", "\<s-tab>")

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

" ===== Open buffer in =====
" Open current document in browser (save it before)
command! OpenInFirefox :call OpenCurrentDocumentInBrowser('firefox')
command! OpenInChrome :call OpenCurrentDocumentInBrowser('chrome')

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

" ===== Misc filetypes =====

augroup global
    autocmd!
    " Cursor on last editing place in every opened file
    autocmd BufReadPost * normal `"     
augroup END

augroup syntax-sugar
    autocmd!
    " Make it so that a curly brace automatically inserts an indented line
    autocmd FileType javascript,css,perl,php inoremap {<CR> {<CR>}<Esc>O
augroup END

" ===== Dosbatch =====
augroup dosbatch
    autocmd!
    " Run dosbatch bat file
    autocmd FileType dosbatch nnoremap <buffer> <leader>c :w<CR>:Clam %:p<CR>gg<C-w>w
augroup END

" ===== HTML =====
augroup html
    autocmd!
    autocmd FileType html setlocal dictionary+=$HOME/vimfiles/bundle/bootstrap-snippets/dictionary
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

" ===== Jira =====
augroup jira
    autocmd!
    " Set filetype automatically
    autocmd BufRead,BufNewFile *.jira setlocal filetype=jira
augroup END

" Create Jira style aligned table from tab separated items of one paragraph
command! JiraTable :call JiraTable()

" ===== Markdown =====
augroup markdown
    autocmd!
    autocmd FileType modula2  setlocal ft         =markdown
    autocmd FileType markdown setlocal textwidth  =80
    autocmd FileType markdown setlocal autoindent
    " autocmd FileType markdown noremap <buffer> <Space> :silent call ToggleTodo()<CR>

    " Underline heading
    autocmd FileType markdown nnoremap <LocalLeader>j m`^y$o<Esc>pVr=``
    " Prefix # heading
    autocmd FileType markdown nnoremap <LocalLeader>h m`:s/^\(#*\)\ \?/#\1\ /<CR>``
    " bold
    autocmd FileType markdown nnoremap <LocalLeader>b viw<Esc>`>a**<Esc>`<i**<Esc>f*;
    autocmd FileType markdown vnoremap <LocalLeader>b <Esc>`>a**<Esc>`<i**<Esc>f*;
    " italics
    autocmd FileType markdown nnoremap <LocalLeader>i viw<Esc>`>a_<Esc>`<i_<Esc>f_
    autocmd FileType markdown vnoremap <LocalLeader>i <Esc>`>a_<Esc>`<i_<Esc>f_
    " inline code
    autocmd FileType markdown nnoremap <LocalLeader>` viw<Esc>`>a`<Esc>`<i`<Esc>f`
    autocmd FileType markdown vnoremap <LocalLeader>` <Esc>`>a`<Esc>`<i`<Esc>f`
    " vnoremap <leader>b o<Esc>i**<Esc>gvoll<Esc>a**<Esc>
    " unordered list
    autocmd FileType markdown nnoremap <LocalLeader>u vip:s/^\(\s*\)/\1- /
    autocmd FileType markdown vnoremap <LocalLeader>u :s/^.\?/\U&/gvI- 
    " Save mkd file
    autocmd FileType markdown nnoremap <LocalLeader>s :1y<CR> :w <C-r>"<BS>.md<CR>
    " Link from address - last segment to be the text
    autocmd FileType markdown nnoremap <LocalLeader>l
            \ :s/\(\(http\\|www\).*\/\)\([^/ \t)]\+\)\(\/\?\)/[\3](&)/<CR>
augroup END

" Create Markdown (GFM) style table from tab separated items of one paragraph
command! MDtable :call MDtable()
" Create Markdown ordered list
command! MDlist :call MDlist()
" Create Markdown main heading from file name
command! MDfiletohead :call MDfiletohead()
" Save as Markdown file with file name same as main heading
command! MDheadtofile :call MDheadtofile()
" Creates Markdown style web links
" Replaces any row and following row with URL with Markdown syntax for links
command! MDlinks :%s/\(.*\)\n\(\(http\|www\).*\)/[\1](\2)/<CR>
" Generate html from current buffer (markdown)
" command! MDhtml :silent !mdhtml %
command! MDhtml call system("cmd.exe /c mdhtml \"" . expand("%:p") . "\"" )
" Open current buffer (markdown) in browser in preview mode
" command! MDopen :silent !mdopen %
command! MDopen call system("cmd.exe /c start firefox \"file:///" . substitute(expand("%:p:r"), "\ ", "%20", "g") . ".html\"" )

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

" ===== SQL =====
augroup sql
    autocmd!
    " Indentation of brackets
    autocmd Filetype sql vnoremap <LocalLeader>s( :s/\(\S\)\ (/\1(/ge<cr><esc>
    " Upper case
    autocmd Filetype sql vnoremap <LocalLeader>su :s/\<update\>\\|\<select\>\\|\<delete\>\\|\<insert\>\\|\<from\>\\|\<where\>\\|\<join\>\\|\< left join\>\\|\<inner join\>\\|\<on\>\\|\<group by\>\\|\<order by\>\\|\<and\>\\|\<or\>\\|\<as\>/\U&/ge<cr><esc>
    " New lines after keywords
    autocmd Filetype sql vnoremap <LocalLeader>sp :s/\(\(\ \{4}\)*\)\(\<update\>\\|\<select\>\\|\<from\>\\|\<where\>\\|\<left join\>\\|\<inner join\>\\|\<group by\>\\|\<order by\>\)\ /&\r\1\t/ge<cr><esc>
    " Expand
    autocmd Filetype sql vnoremap <LocalLeader>se :s/\(\<update\>\\|\<select\>\\|\<from\>\\|\<where\>\\|\<left join\>\\|\<inner join\>\\|\<group by\>\\|\<order by\>\)\_.\{-}\t/\U\1\ /ge<cr><esc>
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
augroup vim
    autocmd!
    autocmd FileType vim setlocal foldmethod=marker
augroup END

" ===== XML (and HTML) =====
" previous tag on same indentation level
nnoremap <C-k> ?^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>nww
" next tag on same indentation level
nnoremap <C-j> /^\s\{<C-r>=indent(".")<CR>}<\w\+<CR>ww
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

" }}}
" ==============================================================================
"  Plugin settings {{{1
" ==============================================================================

" ===== Ag =====
let g:ag_prg="ag --vimgrep --smart-case"
let g:ag_highlight=1

" ===== Autoformat =====
" java
let g:formatprg_java = "astyle"
let g:formatprg_args_java = "--mode=java --style=java"
" js
let g:formatprg_javascript = "js-beautify"
let g:formatprg_args_javascript = "-f -"
" css
let g:formatprg_css = "css-beautify"
let g:formatprg_args_css = "-f -"
" less
let g:formatprg_less = "css-beautify"
let g:formatprg_args_less = "-f -"
" sql - Indent String is 4 space and enable Trailing Commas
let g:formatprg_sql = "sqlformatter"
let g:formatprg_args_sql = "/is:\"    \" /tc /uk- /sk-"

" ===== Auto-pairs =====
let g:AutoPairsFlyMode = 0        " Disable flying over parenthesis
let b:autopairs_enabled = 0       " Disable Auto-pairs on start

" ===== Bookmark =====
let g:bookmark_sign = '>>'            " Sets bookmark icon for sign column
let g:bookmark_annotation_sign = '##' " Sets bookmark annotation icon for sign column
let g:bookmark_auto_close = 1         " Automatically close bookmarks split when jumping to a bookmark
let g:bookmark_highlight_lines = 1    " Enables/disables line highlighting
let g:bookmark_center = 1             " Enables/disables line centering when jumping to bookmark

" ===== CtrlP =====
" Set ctrl+p for normal fuzzy file opening
nnoremap <c-p> :CtrlP<cr>
" Set alt+p for most recently used files
nnoremap <a-p> :CtrlPMRUFiles<cr>

" ===== CSV =====
" let g:csv_no_conceal = 1
" let g:csv_no_column_highlight = 1
hi def link CSVColumnHeaderOdd  vimCommentString
hi def link CSVColumnHeaderEven vimCommentString
hi def link CSVColumnOdd	    vimSynMtchOpt
hi def link CSVColumnEven	    normal

" ===== DelimitMate =====
let g:delimitMate_expand_cr    = 2  " Expand to new line after <cr>
let g:delimitMate_expand_space = 1  " Expand the <space> on both sides
" let g:delimitMate_autoclose  = 0  " Do not add closing delimeter automatically
" let g:delimitMate_offByDefault = 1  " Turn off by default
let delimitMate_excluded_ft = "markdown,txt"
" Run :DelimitMateSwitch to turn on

" ===== Emmet =====
let g:user_emmet_leader_key = '<c-h>'
let g:emmet_html5           = 1

" ===== Fugitive =====
augroup fugitive
    autocmd BufReadPost fugitive://* setlocal bufhidden=delete
augroup END

" ===== Geeknote =====
let g:GeeknoteExplorerNodeClosed = '+'
let g:GeeknoteExplorerNodeOpened = '-'

" ===== GitGutter =====
let g:gitgutter_enabled = 0
let g:gitgutter_signs = 1
nmap [g <Plug>GitGutterPrevHunk
nmap ]g <Plug>GitGutterNextHunk
nmap <LocalLeader>gs <Plug>GitGutterStageHunk
nmap <LocalLeader>gr <Plug>GitGutterRevertHunk

" ===== Goyo =====
let g:goyo_width=100 "(default: 80)
let g:goyo_margin_top=2 " (default: 4)
let g:goyo_margin_bottom=2 " (default: 4)

" ===== Huge file =====
let g:hugefile_trigger_size = 50

" ===== IndentLine =====
let g:indentLine_enabled = 0

" ===== LogViewer =====
let g:LogViewer_Filetypes = 'log' 

" Markdown
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
let g:SuperTabDefaultCompletionType = "context"
let g:SuperTabLongestHighlight = 1
" au FileType css let g:SuperTabDefaultCompletionType = "<c-x><c-o>"
" Probably slowing down
" autocmd FileType *
"       \ if &omnifunc != '' |
"       \     call SuperTabChain(&omnifunc, '<c-p>') |
"       \ endif

" ===== Vim-markdown =====
let g:vim_markdown_folding_disabled=1

" ===== Xml.vim =====
let xml_tag_completion_map = "<c-l>"
" let g:xml_warn_on_duplicate_mapping = 1
" let xml_no_html = 1

" ===== Voom =====
let g:voom_tree_placement = "right"

" ===== Zeavim - Zeal integration =====
let g:zv_zeal_directory = "C:\\Program Files (x86)\\zeal\\zeal.exe"

" }}}
" ==============================================================================
"  Cygwin {{{1
" ==============================================================================

" Fix cursors
" let &t_ti.="\e[1 q"
" let &t_SI.="\e[5 q"
" let &t_EI.="\e[1 q"
" let &t_te.="\e[0 q"

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

" Creates Jira style table from tab separated items of one paragraph
" First line will have double | (pipe) characters as separators
function! JiraTable()
    normal vip:s/\t/|/gvip:s/^/|\ /vip:s/$/\ |/vip:Tab/|{j:s/|\ \?/||/g
endfunction

" Creates Markdown (GFM) style table from tab separated items of one paragraph
" Second line will be a separator between head and body of the table
function! MDtable()
    normal vip:s/\t/|/gvip:Tab/|yyp:s/[^ |]/-/g:s/\([^|]\)\ \([^ |]\)/\1-\2/g
endfunction

" Creates Markdown orderded list
" Adds numbers and align the list
function! MDlist()
    normal vipI1. }k
    :Tab/^[^ ]*\zs\ /l0
endfunction

" Create Markdown main heading from file name
function! MDfiletohead()
    normal ggOi%dF.x0vUyypVr=o
endfunction

" Save as Markdown file with file name same as main heading
function! MDheadtofile()
    normal gg0v$hy:w ".md
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
" http://vimrcfu.com/snippet/171
" :Bufferize digraphs
" :Bufferize syntax
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
    autocmd VimEnter * if g:screen_size_restore_pos == 1 | call ScreenRestore() | endif
    autocmd VimLeavePre * if g:screen_size_restore_pos == 1 | call ScreenSave() | endif
  augroup END
endif
" End of position saving script

" }}}
" ==============================================================================
"  Abbreviations {{{1
" ==============================================================================

" Note
iabbrev note: NOTE [<c-r>=strftime("%Y-%m-%d")<cr> Lukas Trumm]
" My e-mail address
iabbrev mail: lukas.trumm@centrum.cz

" }}}
" ==============================================================================
"  Examples {{{1
" ==============================================================================

" Process all lines function
"""""
" for linenumber in range(a:firstline, a:lastline)
"     let line = getline(linenumber)
"     let cleanLine = substitute(line, '', '', '')
"     call setline(linenumber, cleanLine)
" endfor
"""""

" }}}
" ==============================================================================
"  Test {{{1
" ==============================================================================

" set noshelltemp " experimental " Should avoid some cmd windows for external commands

