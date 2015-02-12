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

" Hide Toolbar
if has("gui_running")
    set guioptions=egmrt
    set guifont=Droid\ Sans\ Mono\ for \Powerline:h12
endif

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

" Vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'
Bundle 'leafgarland/typescript-vim.git'
Bundle 'tpope/vim-fugitive.git'
Bundle 'tpope/vim-surround.git'
Bundle 'tComment'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle 'chriskempson/tomorrow-theme.git', { 'rtp': 'vim/' }
Bundle 'groenewege/vim-less.git'
Bundle 'digitaltoad/vim-jade.git'
Bundle 'pangloss/vim-javascript.git'
Bundle 'wting/rust.vim.git'
Bundle 'hylang/vim-hy.git'
Bundle 'gorkunov/smartpairs.vim.git'
Bundle 'JuliaLang/julia-vim'

Bundle 'scrooloose/nerdtree.git'

function! ToggleNerdTree()
  if !exists("b:NERDTreeType")
    execute "NERDTree"
  else
    execute "NERDTreeToggle"
  endif
endfunction

map <Leader>n :call ToggleNerdTree()<CR>
map - :call ToggleNerdTree()<CR>

Bundle 'Shougo/unite.vim.git'
Bundle 'Shougo/vimproc.vim.git'
Bundle 't9md/vim-unite-ack'
Bundle 'osyo-manga/unite-quickfix'
Bundle 'rking/ag.vim'

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
call unite#filters#sorter_default#use(['sorter_rank'])
let g:unite_source_history_yank_enable = 1
let g:unite_source_grep_command = 'ag'

map <expr> <C-@> ':Unite -start-insert -toggle buffer<CR>'
inoremap <expr> <C-@> '<Esc>:UniteClose<CR>'

map <Leader>uf :Unite -toggle -start-insert file_rec<CR>
map <Leader>ug :exe 'silent Ggrep -i '.input("Pattern: ")<Bar>Unite quickfix -no-quit -auto-preview<CR>
map <Leader>u* :exe 'silent Ggrep -i '.expand("<cword>")<Bar>Unite quickfix -no-quit<CR>
map <Leader>ub :Unite -toggle -start-insert buffer<CR>
map <Leader>uq :Unite -toggle quickfix<CR>
map <Leader>ux :Unite command<CR>
map <Leader>ut :Unite -toggle -start-insert tab<CR>
map <Leader>up :Unite -toggle -start-insert process<CR>

Bundle 'Raimondi/delimitMate.git'
Bundle 'tmhedberg/matchit.git'
Bundle 'junegunn/vim-easy-align.git'

map <Leader>t :EasyAlign<CR>

Bundle 'fatih/vim-go.git'

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
set encoding=utf-8
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

" Folding
set foldmethod=indent
set foldlevel=100

" Search
set incsearch
let g:incsearch#auto_nohlsearch = 1
set ignorecase
set smartcase
set complete-=i

" disable word wrapping
set nowrap

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
nnoremap <Leader>l :set norelativenumber!<CR>

" faster quickfix naviation
map ]q :cnext<CR>
map [q :cprevious<CR>

" faster buffer naviation
map ]b :bnext<CR>
map [b :bprevious<CR>

" faster tab naviation
map ]t :tnext<CR>
map [t :tprevious<CR>

" faster pane switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" Create file under cursor
map gF :e <cfile><cr>

" Delete all hidden buffers
function! Wipeout()
  let l:buffers = range(1, bufnr('$'))
  let l:currentTab = tabpagenr()
  try
    let l:tab = 0
    while l:tab < tabpagenr('$')
      let l:tab += 1
      let l:win = 0
      while l:win < winnr('$')
        let l:win += 1
        let l:thisbuf = winbufnr(l:win)
        call remove(l:buffers, index(l:buffers, l:thisbuf))
      endwhile
    endwhile
    if len(l:buffers)
      execute 'bwipeout' join(l:buffers)
    endif
  finally
    execute 'tabnext' l:currentTab
  endtry
endfunction

map <Leader>o :call Wipeout()<CR>
