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
Bundle 'tpope/vim-surround.git'
Bundle 'tComment'
Bundle "MarcWeber/vim-addon-mw-utils"
Bundle "tomtom/tlib_vim"
Bundle "garbas/vim-snipmate"
Bundle "honza/vim-snippets"
Bundle "tpope/vim-fugitive"
Bundle 'chriskempson/tomorrow-theme.git', { 'rtp': 'vim/' }
Bundle 'groenewege/vim-less.git'
Bundle 'digitaltoad/vim-jade.git'
Bundle 'pangloss/vim-javascript.git'
Bundle 'wting/rust.vim.git'
Bundle 'hylang/vim-hy.git'
Bundle 'JuliaLang/julia-vim'
Bundle 'junegunn/goyo.vim.git'

map <Leader>d :Goyo<CR>

function! s:goyo_enter()
  set relativenumber
  set number
endfunction

autocmd! User GoyoEnter
autocmd  User GoyoEnter nested call <SID>goyo_enter()

Bundle 'tpope/vim-vinegar'

map <Leader>n :call VexToggle("")<CR>

" ··········· netrw ···················· {{{2
fun! VexToggle(dir)
  if exists("t:vex_buf_nr")
    call VexClose()
  else
    call VexOpen(a:dir)
  endif
endf

fun! VexOpen(dir)

  " Close Goyo
  exe "Goyo!"
  if exists("t:vex_buf_nr")
    return
  endif

  let g:netrw_browse_split=4    " open files in previous window
  let g:netrw_banner=0          " no banner
  let vex_width = 27

  exe "Vexplore " . a:dir
  let t:vex_buf_nr = bufnr("%")
  wincmd H

  call VexSize(vex_width)
endf

fun! VexClose()
  let cur_win_nr = winnr()
  let target_nr = ( cur_win_nr == 1 ? winnr("#") : cur_win_nr )

  1wincmd w
  close
  unlet t:vex_buf_nr

  exe (target_nr - 1) . "wincmd w"
  call NormalizeWidths()
endf

fun! VexSize(vex_width)
  exe "vertical resize" . a:vex_width
  set winfixwidth
  call NormalizeWidths()
endf

fun! NormalizeWidths()
  let eadir_pref = &eadirection
  set eadirection=hor
  set equalalways! equalalways!
  let &eadirection = eadir_pref
endf

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
map <Leader>ug :exe 'silent Ggrep -i '.input("Pattern: ")<Bar>Unite quickfix -no-quit<CR>
map <Leader>ub :Unite -toggle -start-insert buffer<CR>
map <Leader>uq :Unite -toggle quickfix<CR>
map <Leader>ux :Unite command<CR>
map <Leader>ut :Unite -toggle -start-insert tab<CR>
map <Leader>up :Unite -toggle -start-insert process<CR>

Bundle 'mhinz/vim-startify.git'
Bundle 'Raimondi/delimitMate.git'
Bundle 'tmhedberg/matchit.git'
Bundle 'godlygeek/tabular.git'

" Tabularize
command! -nargs=1 -range TabFirst exec <line1> . ',' . <line2> . 'Tabularize /^[^' . escape(<q-args>, '\^$.[?*~') . ']*\zs' . escape(<q-args>, '\^$.[?*~')
command! -nargs=1 -range Tab exec <line1> . ',' . <line2> . 'Tabularize /' . escape(<q-args>, '\^$.[?*~') 
map <Leader>t :TabFirst 

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

let g:startify_custom_header = map(split(system('quotes'), '\n'), '"\t\t" . v:val')

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

" select pasted
nnoremap gp `[v`]

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

" faster pane switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

