" Ilia's VIM 

set shell=zsh
set nocompatible
set nofixendofline

" Plugins
call plug#begin('~/.vim/plugged')

Plug 'tpope/vim-fugitive'

" Editing

Plug 'junegunn/goyo.vim'
" Plug 'Raimondi/delimitMate'
Plug 'wellle/targets.vim'
Plug 'tpope/vim-surround'
Plug 'junegunn/vim-easy-align'
Plug 'tomtom/tcomment_vim'
Plug 'tmhedberg/matchit'
Plug 'tpope/vim-sleuth'

" Navigation

Plug 'schickling/vim-bufonly'
Plug 'preservim/nerdtree'
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" Pretty

Plug 'bling/vim-airline'
Plug 'chriskempson/base16-vim'

" Language Support

Plug 'Valloric/YouCompleteMe'
Plug 'jason0x43/vim-js-indent', { 'for': 'js' }
Plug 'fatih/vim-go'
Plug 'alunny/pegjs-vim'
Plug 'itegulov/vim-epl-syntax'
Plug 'b4b4r07/vim-hcl'
Plug 'leafgarland/typescript-vim'

call plug#end()

" enable syntax
syntax on

" Automatically change filetype
augroup filetype_detect_on_rename
  autocmd!
  autocmd BufFilePost * filetype detect
augroup END

" TypeScript uses json with comments
autocmd BufNewFile,BufRead tsconfig.*json set syntax=javascript

" Dictionary
set dictionary+=/usr/share/dict/words

" Folding
set foldmethod=indent
set foldlevel=100
set foldlevelstart=100

" The javascript plugin makes vim hang
let g:polyglot_disabled = ['javascript', 'graphql', 'typescript', 'ts']

" GoDef
let g:godef_split=0
let g:godef_same_file_in_same_window=1
let g:go_autodetect_gopath=0

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
set fillchars=vert:│

" Font
set t_Co=256

if filereadable(expand("~/.vimrc_background"))
  let base16colorspace=256
  source ~/.vimrc_background
endif

highlight Pmenu ctermfg=15 ctermbg=Grey guifg=#ffffff guibg=Grey
highlight Visual ctermfg=15 ctermbg=Grey guifg=#ffffff guibg=Grey
highlight VertSplit cterm=None

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

" YouCompleteMe
autocmd FileType java map gd :YcmCompleter GoTo<CR>
autocmd FileType java map gt :YcmCompleter GoToType<CR>
autocmd FileType java map gr :YcmCompleter GoToReferences<CR>
autocmd FileType java map gn :YcmCompleter RefactorRename
autocmd FileType java map K :YcmCompleter GetDoc<CR>

autocmd FileType typescript map gd :YcmCompleter GoToDefinition<CR>
autocmd FileType typescript map gt :YcmCompleter GoToType<CR>
autocmd FileType typescript map gr :YcmCompleter GoToReferences<CR>
autocmd FileType typescript map gn :YcmCompleter RefactorRename
autocmd FileType typescript map K :YcmCompleter GetDoc<CR>

autocmd FileType go map gd :YcmCompleter GoTo<CR>
autocmd FileType go map gt :YcmCompleter GoToType<CR>
autocmd FileType go map gr :YcmCompleter GoToReferences<CR>
autocmd FileType go map gn :YcmCompleter RefactorRename
autocmd FileType go map K :YcmCompleter GetDoc<CR>

let g:ycm_key_invoke_completion = ''
let g:go_def_mode='gopls'
let g:go_info_mode='gopls'

" Easy Align
map <Leader>t :EasyAlign 

" NerdTree
let NERDTreeMapHelp='<f1>'
map <Leader>n :NERDTreeToggle<CR>
map <Leader>m :NERDTreeFind<CR>

" Goyp
map <Leader>g :Goyo<CR>

function! s:goyo_enter()
  set wrap
  set linebreak
endfunction

function! s:goyo_leave()
  set nowrap
  set nolinebreak
endfunction

autocmd! User GoyoEnter nested call <SID>goyo_enter()
autocmd! User GoyoLeave nested call <SID>goyo_leave()

" FZF
map <expr> <C-@> '<ESC>:Buffers<CR>'
map <expr> <C-F> '<ESC>:Files<CR>'
inoremap <expr> <C-@> '<ESC>:Buffers<CR>'
inoremap <expr> <C-F> '<ESC>:Files<CR>'

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
map <Leader>gs :Gstatus<CR>
map <Leader>gd :Gvdiff<CR>
map <Leader>gc :Gcommit<CR>
map <Leader>ge :Gedit<CR>
map <Leader>gr :Gread<CR>
map <Leader>gw :Gwrite<CR>
map <Leader>gp :Git push<CR>

" Commands
command! W :w
command! CopyLocationToClipboard execute "let @+=expand(\"%:p\").\":\".line(\".\")"

" Faster Scrolling
nnoremap <C-e> 3<C-e>
nnoremap <C-y> 3<C-y>
