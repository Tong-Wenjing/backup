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
"Bundle 'asciidoc.vim'
"Bundle 'confluencewiki.vim'
"Bundle 'html5.vim'
Bundle 'JavaScript-syntax'
"Bundle 'moin.vim'
Bundle 'python.vim--Vasiliev'
"Bundle 'xml.vim'
Bundle 'spf13/PIV'
"
""Color
"Bundle 'desert256.vim'
"Bundle 'Impact'
"Bundle 'matrix.vim'
"Bundle 'vibrantink'
Bundle 'vividchalk.vim'
"
""Intent
"Bundle 'IndentAnything'
Bundle 'Javascript-Indentation'
"Bundle 'mako.vim--Torborg'
Bundle 'php.vim'
Bundle 'gg/python.vim'
"
""Plugin
Bundle 'AutoClose--Alves'
Bundle 'Shougo/neocomplete.vim'
Bundle 'Shougo/neosnippet.vim'
Bundle 'jsbeautify'
"Bundle 'jshint2.vim'
Bundle 'taglist.vim'
"Bundle 'css_color.vim'
"Bundle 'hallettj/jslint.vim'
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
syntax on
"Auto switch to current directory
"au BufRead,BufNewFile,BufEnter * cd %:p:h

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
"colorscheme mystyle_dark
"colorscheme mystyle_white
"colorscheme desert256
colorscheme vividchalk
"colorscheme vibrantink
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
"set paste

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
                               \ 'active_filetypes': ['python', 'php', 'javascript'],
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
let g:syntastic_python_checkers=['pyflakes']
"-----------
"javascript syntax checker
"----------
let g:syntastic_javascript_checkers=['jshint']

""""""""""""""""""""""""""
"neocomplete
"""""""""""""""""""""""""
" Disable AutoComplPop.
let g:acp_enableAtStartup = 0
" Use neocomplete.
let g:neocomplete#enable_at_startup = 1
" Use smartcase.
let g:neocomplete#enable_smart_case = 1
" Set minimum syntax keyword length.
let g:neocomplete#sources#syntax#min_keyword_length = 3
let g:neocomplete#lock_buffer_name_pattern = '\*ku\*'

" Define dictionary.
let g:neocomplete#sources#dictionary#dictionaries = {
    \ 'default' : '',
    \ 'vimshell' : $HOME.'/.vimshell_hist',
    \ 'scheme' : $HOME.'/.gosh_completions'
        \ }

" Define keyword.
if !exists('g:neocomplete#keyword_patterns')
    let g:neocomplete#keyword_patterns = {}
endif
let g:neocomplete#keyword_patterns['default'] = '\h\w*'

" Plugin key-mappings.
inoremap <expr><C-g>     neocomplete#undo_completion()
inoremap <expr><C-l>     neocomplete#complete_common_string()

" Recommended key-mappings.
" <CR>: close popup and save indent.
inoremap <silent> <CR> <C-r>=<SID>my_cr_function()<CR>
function! s:my_cr_function()
  return neocomplete#smart_close_popup() . "\<CR>"
  " For no inserting <CR> key.
  "return pumvisible() ? neocomplete#close_popup() : "\<CR>"
endfunction
" <TAB>: completion.
inoremap <expr><TAB>  pumvisible() ? "\<C-n>" : "\<TAB>"
" <C-h>, <BS>: close popup and delete backword char.
inoremap <expr><C-h> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><BS> neocomplete#smart_close_popup()."\<C-h>"
inoremap <expr><C-y>  neocomplete#close_popup()
inoremap <expr><C-e>  neocomplete#cancel_popup()
" Close popup by <Space>.
"inoremap <expr><Space> pumvisible() ? neocomplete#close_popup() : "\<Space>"

" For cursor moving in insert mode(Not recommended)
"inoremap <expr><Left>  neocomplete#close_popup() . "\<Left>"
"inoremap <expr><Right> neocomplete#close_popup() . "\<Right>"
"inoremap <expr><Up>    neocomplete#close_popup() . "\<Up>"
"inoremap <expr><Down>  neocomplete#close_popup() . "\<Down>"
" Or set this.
"let g:neocomplete#enable_cursor_hold_i = 1
" Or set this.
"let g:neocomplete#enable_insert_char_pre = 1

" AutoComplPop like behavior.
"let g:neocomplete#enable_auto_select = 1

" Shell like behavior(not recommended).
"set completeopt+=longest
"let g:neocomplete#enable_auto_select = 1
"let g:neocomplete#disable_auto_complete = 1
"inoremap <expr><TAB>  pumvisible() ? "\<Down>" : "\<C-x>\<C-u>"

" Enable omni completion.
autocmd FileType css setlocal omnifunc=csscomplete#CompleteCSS
autocmd FileType html,markdown setlocal omnifunc=htmlcomplete#CompleteTags
autocmd FileType javascript setlocal omnifunc=javascriptcomplete#CompleteJS
autocmd FileType python setlocal omnifunc=pythoncomplete#Complete
autocmd FileType xml setlocal omnifunc=xmlcomplete#CompleteTags

" Enable heavy omni completion.
if !exists('g:neocomplete#sources#omni#input_patterns')
  let g:neocomplete#sources#omni#input_patterns = {}
endif
"let g:neocomplete#sources#omni#input_patterns.php = '[^. \t]->\h\w*\|\h\w*::'
"let g:neocomplete#sources#omni#input_patterns.c = '[^.[:digit:] *\t]\%(\.\|->\)'
"let g:neocomplete#sources#omni#input_patterns.cpp = '[^.[:digit:] *\t]\%(\.\|->\)\|\h\w*::'

" For perlomni.vim setting.
" https://github.com/c9s/perlomni.vim
let g:neocomplete#sources#omni#input_patterns.perl = '\h\w*->\h\w*\|\h\w*::'

"Auto load the .vimrc
autocmd! bufwritepost .vimrc source ~/.vimrc

