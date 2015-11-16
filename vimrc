" Ilia's VIM 

set shell=zsh
set nocompatible

" disable splash
set shortmess+=I

" leader
let mapleader = "\<Space>"
nnoremap <Space> <Nop>

" enable mouse
set mouse=a

" enable syntax
syntax on

" Automatically change filetype
if has('autocmd')
  " assuming filetype plugin indent on
  augroup filetype_detect_on_rename
    autocmd!
    autocmd BufFilePost * filetype detect
  augroup END
endif

" Dictionary
set dictionary+=/usr/share/dict/words

" Folding
set foldmethod=indent
set foldlevel=100
set foldlevelstart=100

" Vundle
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#rc()

Bundle 'gmarik/Vundle.vim'

Bundle 'junegunn/fzf'
Bundle 'icholy/fzf.vim'

map <Leader>ff :GitFiles<CR>
map <Leader>gg :GitGrep 


Bundle 'marijnh/tern_for_vim'
Bundle 'kassio/neoterm'

nnoremap <silent> <f5> :call neoterm#repl#line()<cr>
vnoremap <silent> <f5> :call neoterm#repl#selection()<cr>
tnoremap <C-h> <C-\><C-n><C-w>h
tnoremap <C-j> <C-\><C-n><C-w>j
tnoremap <C-k> <C-\><C-n><C-w>k
tnoremap <C-l> <C-\><C-n><C-w>l
tnoremap jk <C-\><C-n>

set wildcharm=<Tab>

Bundle 'sheerun/vim-polyglot'

let g:polyglot_disabled = ['javascript']

Bundle 'jason0x43/vim-js-indent'
Bundle 'tpope/vim-fugitive'

map <Leader>gs :Gstatus<CR>
map <Leader>gd :Gdiff<CR>
map <Leader>gc :Gcommit<CR>
map <Leader>ge :Gedit<CR>
map <Leader>gr :Gread<CR>
map <Leader>gw :Gwrite<CR>
map <Leader>gp :Git push<CR>

Bundle 'tpope/vim-surround'
Bundle 'tComment'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle 'chriskempson/tomorrow-theme', { 'rtp': 'vim/' }
Bundle 'hylang/vim-hy'
Bundle 'gorkunov/smartpairs.vim'
Bundle 'scrooloose/nerdtree'

function! ToggleNerdTree()
  if !exists("b:NERDTreeType")
    execute "NERDTree"
  else
    execute "NERDTreeToggle"
  endif
endfunction

let NERDTreeMapHelp='<f1>'
map <Leader>n :NERDTreeToggle<CR>

Bundle 'Shougo/unite.vim'
Bundle 'Shougo/vimproc.vim'
Bundle 't9md/vim-unite-ack'
Bundle 'osyo-manga/unite-quickfix'
Bundle 'rking/ag.vim'

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
let g:unite_source_history_yank_enable = 1
map <expr> <C-@> ':Unite -start-insert -toggle buffer<CR>'
inoremap <expr> <C-@> '<ESC>:Unite -start-insert -toggle buffer<CR>'

Bundle 'Raimondi/delimitMate'
Bundle 'tmhedberg/matchit'
Bundle 'junegunn/vim-easy-align'

map <Leader>t :EasyAlign<CR>

Bundle 'fatih/vim-go'

" GoDef
let g:godef_split=0
let g:godef_same_file_in_same_window=1

Bundle 'bling/vim-airline'

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


" Other
filetype plugin indent on
set backspace=indent,eol,start
set listchars=tab:↪\ ,extends:❯,precedes:❮,nbsp:␣,eol:$

" Font
set t_Co=256
colorscheme Tomorrow

" Spacing
set autoindent
set expandtab
set tabstop=2
set shiftwidth=2

" Stuff
set colorcolumn=+1
set timeoutlen=300
set hidden
set wildmenu
set wildmode=list:longest
set laststatus=2

command! W :w
noremap <leader>w :w !sudo tee %<CR>
nnoremap Q <nop>

inoremap kj <Esc>
inoremap jk <Esc>
inoremap <C-C> <Nop>

" select pasted
nnoremap gp `[v`]

" faster replace
nnoremap <Leader>s :%s/<C-r><C-w>/

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

" faster quickfix naviation
map ]q :cnext<CR>
map [q :cprevious<CR>

" faster buffer naviation
map ]b :bnext<CR>
map [b :bprevious<CR>

" faster tab naviation
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

Bundle 'schickling/vim-bufonly'

map <Leader>o :BufOnly<CR>

Bundle 'Quramy/tsuquyomi'
let g:tsuquyomi_definition_split = 0

Bundle 'Valloric/YouCompleteMe'

if !exists("g:ycm_semantic_triggers")
   let g:ycm_semantic_triggers = {}
endif
let g:ycm_key_invoke_completion = ''
let g:ycm_semantic_triggers['javascript'] = ['.']
set completeopt-=preview

autocmd FileType typescript map gd :YcmCompleter GoToDefinition<CR>
autocmd FileType typescript map K :YcmCompleter GetDoc<CR>

