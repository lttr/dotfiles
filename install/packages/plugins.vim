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
Plug 'terryma/vim-multiple-cursors'
Plug 'triglav/vim-visual-increment'
Plug 'tpope/vim-unimpaired'

" Files
Plug 'ctrlpvim/ctrlp.vim'
Plug 'airblade/vim-rooter'
Plug 'rking/ag.vim'
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
Plug 'ternjs/tern_for_vim' , { 'for': 'javascript' }
Plug 'othree/javascript-libraries-syntax.vim'
Plug 'arturbalabanov/vim-angular-template'
Plug 'elzr/vim-json'

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
Plug 'Shebang'
Plug 'fboender/bexec'

" Special file types
Plug 'chrisbra/csv.vim', { 'for': 'csvx' }
Plug 'dzeban/vim-log-syntax' , { 'for': 'log' }
Plug 'andreshazard/vim-freemarker' , { 'for': 'freemarker' }
Plug 'vobornik/vim-mql4' , { 'for': 'mql4' }
Plug 'vim-scripts/dbext.vim' , { 'for': 'sql' }
Plug 'vim-scripts/gnuplot.vim' , { 'for': 'gnuplot' }
Plug 'gabrielelana/vim-markdown' , { 'for': 'markdown' }

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
