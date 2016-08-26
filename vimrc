" Ilia's VIM 

set shell=zsh
set nocompatible

" Plugins
call plug#begin('~/.vim/plugged')

Plug 'powerman/vim-plugin-autosess'
Plug 'wellle/targets.vim'
Plug 'dhruvasagar/vim-table-mode'
Plug 'junegunn/fzf'
Plug 'icholy/fzf.vim'
Plug 'sheerun/vim-polyglot'
Plug 'jason0x43/vim-js-indent'
Plug 'tpope/vim-fugitive'
Plug 'tpope/vim-surround'
Plug 'tComment'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'tomtom/tlib_vim'
Plug 'chriskempson/tomorrow-theme', { 'rtp': 'vim/' }
Plug 'hylang/vim-hy'
Plug 'gorkunov/smartpairs.vim'
Plug 'scrooloose/nerdtree'
Plug 'Shougo/unite.vim'
Plug 'Shougo/vimproc.vim'
Plug 't9md/vim-unite-ack'
Plug 'osyo-manga/unite-quickfix'
Plug 'rking/ag.vim'
Plug 'Raimondi/delimitMate'
Plug 'tmhedberg/matchit'
Plug 'junegunn/vim-easy-align'
Plug 'fatih/vim-go'
Plug 'bling/vim-airline'
Plug 'schickling/vim-bufonly'
Plug 'Valloric/YouCompleteMe'

call plug#end()

" enable syntax
syntax on

" Automatically change filetype
augroup filetype_detect_on_rename
  autocmd!
  autocmd BufFilePost * filetype detect
augroup END

" Dictionary
set dictionary+=/usr/share/dict/words

" Folding
set foldmethod=indent
set foldlevel=100
set foldlevelstart=100

" The javascript plugin makes vim hang
let g:polyglot_disabled = ['javascript']

" NerdTree
function! ToggleNerdTree()
  if !exists("b:NERDTreeType")
    execute "NERDTree"
  else
    execute "NERDTreeToggle"
  endif
endfunction

let NERDTreeMapHelp='<f1>'
map <Leader>n :NERDTreeToggle<CR>

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
let g:unite_source_history_yank_enable = 1
map <expr> <C-@> ':Unite -start-insert -toggle buffer<CR>'
inoremap <expr> <C-@> '<ESC>:Unite -start-insert -toggle buffer<CR>'

" Easy Align
map <Leader>t :EasyAlign<CR>

" GoDef
let g:godef_split=0
let g:godef_same_file_in_same_window=1

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#left_sep = ''

if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif

let g:airline_left_sep = ''
let g:airline_left_alt_sep = ''
let g:airline_right_sep = ''
let g:airline_right_alt_sep = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = ''
let g:airline_symbols.linenr = ''

let g:airline_section_b = '%{strftime("%c")}'
let g:airline_section_y = 'BN: %{bufnr("%")}'

" YouCompleteMe
autocmd FileType typescript map gd :YcmCompleter GoToDefinition<CR>
autocmd FileType typescript map gt :YcmCompleter GoToType<CR>
autocmd FileType typescript map gr :YcmCompleter GoToReferences<CR>
autocmd FileType typescript map K :YcmCompleter GetDoc<CR>

nnoremap <C-LeftMouse> <LeftMouse>:YcmCompleter GoToDefinition<CR>

" Other
set mouse=a
set shortmess+=I
filetype plugin indent on
set backspace=indent,eol,start
set listchars=tab:↪\ ,extends:❯,precedes:❮,nbsp:␣,eol:$
set colorcolumn=+1
set timeoutlen=300
set hidden
set wildmenu
set wildmode=list:longest
set laststatus=2
set wildcharm=<Tab>
set completeopt-=preview

" Font
set t_Co=256
colorscheme Tomorrow

" Spacing
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2

" Backups
set backup
set backupdir-=.
set backupdir^=~/tmp,/tmp
set noswapfile
set nowritebackup
set autoread

" Faster Scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>

" Search
set incsearch
let g:incsearch#auto_nohlsearch = 1
set nohlsearch
set ignorecase
set smartcase
set complete-=i

" disable word wrapping
set nowrap
autocmd BufReadPost quickfix set wrap

" Key Mappings

" leader
let mapleader = "\<Space>"
nnoremap <Space> <Nop>

" disable arrow keys
map <up> <nop>
map <down> <nop>
map <left> <nop>
map <right> <nop>
imap <up> <nop>
imap <down> <nop>
imap <left> <nop>
imap <right> <nop>

" relative line numbers 
set relativenumber
set number

" faster switching
map ]q :cnext<CR>
map [q :cprevious<CR>
map ]b :bnext<CR>
map [b :bprevious<CR>
map ]t :tabnext<CR>
map [t :tabprevious<CR>

" faster pane switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" move lines up/down in visual mode
vnoremap <C-j> :m '>+1<CR>gv=gv
vnoremap <C-k> :m '<-2<CR>gv=gv

" Misc
noremap <leader>w :w !sudo tee %<CR>
nnoremap Q <nop>
inoremap kj <Esc>
inoremap jk <Esc>
inoremap <C-C> <Nop>
nnoremap gp `[v`]
nnoremap <Leader>s :%s/<C-r><C-w>/
map <Leader>o :BufOnly<CR>

" Git
map <Leader>ff :GitFiles<CR>
map <Leader>gg :GitGrep 
map <Leader>gs :Gstatus<CR>
map <Leader>gd :Gdiff<CR>
map <Leader>gc :Gcommit<CR>
map <Leader>ge :Gedit<CR>
map <Leader>gr :Gread<CR>
map <Leader>gw :Gwrite<CR>
map <Leader>gp :Git push<CR>

" Commands
command! W :w
command! CopyLocationToClipboard execute "let @+=expand(\"%:p\").\":\".line(\".\")"
