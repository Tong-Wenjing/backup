"Config vundle
set nocompatible  "be iMproved
filetype off  "required

set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

"let Vundle manage Vundle
"required!
Bundle 'gmarik/vundle'

"My bundle here:
"Original repos on github
"
"vim-script repo
"
"Syntax
Bundle 'asciidoc.vim'
Bundle 'confluencewiki.vim'
Bundle 'html5.vim'
Bundle 'JavaScript-syntax'
Bundle 'moin.vim'
Bundle 'python.vim--Vasiliev'
Bundle 'xml.vim'
"
""Color
Bundle 'desert256.vim'
Bundle 'Impact'
Bundle 'matrix.vim'
Bundle 'vibrantink'
Bundle 'vividchalk.vim'
"
""Intent
Bundle 'IndentAnything'
Bundle 'Javascript-Indentation'
Bundle 'mako.vim--Torborg'
Bundle 'gg/python.vim'
"
""Plugin
Bundle 'AutoClose--Alves'
Bundle 'jsbeautify'
Bundle 'jshint2.vim'
Bundle 'taglist.vim'
"Bundle 'css_color.vim'
Bundle 'hallettj/jslint.vim'
Bundle 'Syntastic'
"Bundle 'ZenCoding.vim'
Bundle 'tpope/vim-fugitive'

"---------------------------------------------------------
"Some common configuration
"---------------------------------------------------------
filetype on
filetype plugin on
filetype plugin indent on  "required!
let mapleader=','
let g:mapleader=','
"syntx enable
syntax enable
"Auto switch to current directory
au BufRead,BufNewFile,BufEnter * cd %:p:h

"allow backspacing over everything in insert mode 
set backspace=indent,eol,start
"Ignore case when searching
set ignorecase
"When searching try to be smart about cases
set smartcase
"Hightlight search results
set hlsearch
"Makes search like search in modern browser
set incsearch
"Use spaces instead of tabs
set expandtab
"Be smart when using tabs
set smarttab
"1 tab = 4 spaces
set shiftwidth=4
set tabstop=4
"Always show current position
set ruler
"Hight of the command bar 
set cmdheight=2
"Set 256 colors
set t_Co=256
"Color schema
colorscheme mystyle_dark
"fold setting
set foldenable
set foldmethod=indent
"auto reload file
set autoread
"set line number
set number
"hightlight the line
set cursorline
"backup before save
set writebackup
"disable backup after save
set nobackup

"Status bar configuration
set laststatus=2  "always has status line
set statusline=%F%m%r%h%w\[TYPE=%Y]\[POS=%04l,%04v]\[%p%%]
set statusline+=%=\%{fugitive#statusline()}
set statusline+=%{SyntasticStatuslineFlag()}


"------------------------------------------------------------
"Key mapping
"------------------------------------------------------------
"use space to turn on/off fold
nnoremap <space> @=((foldclosed(line('.')) < 0) ? 'zc' : 'zo')<CR>
"move while in insert mode
imap <c-k> <Up>
imap <c-j> <Down>
imap <c-h> <Left>
imap <c-l> <Right>

""""""""""""""""""""""""""""""""""""""""
"Netrw setting
""""""""""""""""""""""""""""""""""""""""
let g:netrw_winsize = 30
nmap <silent> fe :Explore<cr> 

"""""""""""""""""""""""""""""""""""""""""
"Tag list (ctags)
""""""""""""""""""""""""""""""""""""""""
let Tlist_Ctags_Cmd = '/usr/bin/ctags'  
"let Tlist_Close_On_Select = 1
let Tlist_Exit_OnlyWindow = 1
let Tlist_Use_Right_Window = 1 
let Tlist_Show_One_File = 1
let Tlist_Sort_Type = "name"
map <silent> <F9> :TlistToggle<cr>


""""""""""""""""""""""""""""""""""""""""
"BufExploer
""""""""""""""""""""""""""""""""""""""""
let g:bufExplorerDefaultHelp = 0       " Do not show default help.
let g:bufExplorerShowRelativePath = 1  " Show relative paths.
let g:bufExplorerSortBy = 'mru'        " Sort by most recently used.
"let g:bufExplorerSplitRight = 1        " Split left.
"let g:bufExplorerHorizontalSplit = 1     " Split vertically.
"let g:bufExplorerSplitVertSize = 30  " Split width
"let g:bufExplorerUseCurrentWindow = 1  " Open in new window.
let g:bufExplorerSplitBelow = 1
map <silent> be :BufExplorerHorizontalSplit<cr>

""""""""""""""""""""""""""""""
" winManager setting
""""""""""""""""""""""""""""""
let g:winManagerWindowLayout = "BufExplorer,FileExplorer|TagList"
let g:winManagerWidth = 30
let g:defaultExplorer = 0
let g:bufExplorerSplitRight = 0
nmap <silent> <C-W><C-F> :FirstExplorerWindow<cr>
nmap <silent> <C-W><C-B> :BottomExplorerWindow<cr>
nmap <silent> wm :WMToggle<cr>

""""""""""""""""""""""""""""""
"lookupfile setting
""""""""""""""""""""""""""""""
let g:LookupFile_MinPatLength = 2               
let g:LookupFile_PreserveLastPattern = 0        
let g:LookupFile_PreservePatternHistory = 1     
let g:LookupFile_AlwaysAcceptFirst = 1          
let g:LookupFile_AllowNewFiles = 0              
nmap <silent> <leader>lk <Plug>LookupFile<cr>   
nmap <silent> <leader>lb :LUBufs<cr>           
nmap <silent> <leader>lw :LUWalk<cr>            
nmap <silent> <leader>q :<C-W>q

""""""""""""""""""""""""""""""
"NERDtree setting
"""""""""""""""""""""""""""""
map <f3> :NERDTreeToggle <CR>
let NERDChristmasTree=1
let NERDTreeAutoCenter=1
"let NERDTreeBookmarksFile=$VIM.'\Data\NerdBookmarks.txt'
"let NERDTreeMouseMode=2
"let NERDTreeShowBookmarks=1"
let NERDTreeQuitOnOpen=1
let NERDTreeShowFiles=1
let NERDTreeShowHidden=1
let NERDTreeShowLineNumbers=1
let NERDTreeWinPos='right'
let NERDTreeWinSize=31 
let NERDTreeDirArrows=1

""""""""""""""""""""""""""""""
"Python diction
""""""""""""""""""""""""""""""
let g:pydiction_location = '/root/.vim/after/ftplugin/pydiction/complete-dict'
let g:pydiction_menu_height = 20

"""""""""""""""""""""""""""""
"Syntastic
""""""""""""""""""""""""""""
let g:syntastic_check_on_open=1
let g:syntastic_auto_jump=1
let g:syntastic_mode_map = { 'mode': 'active',
                               \ 'active_filetypes': ['python', 'php'],
                               \ 'passive_filetypes': ['puppet'] }
let g:syntastic_stl_format = '[%E{Err: %fe #%e}%B{, }%W{Warn: %fw #%w}]'
let g:syntastic_always_populate_loc_list=1
"-----------
"php syntax checker 
"-----------
let g:syntastic_php_checkers=['php', 'phpcs', 'phpmd']
"let g:syntastic_php_phpcs_args="--tab-width=4 --standard=CodeIgniter"
"let makeprg="php -l -d error_reporting=E_All -d display_errors=1"
"-----------
"python syntax checker
"-----------
let g:syntastic_python_checkers = ['pyflakes']


"Auto load the .vimrc
autocmd! bufwritepost .vimrc source ~/.vimrc

