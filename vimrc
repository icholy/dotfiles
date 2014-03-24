" Ilia's VIM 

set shell=zsh
set nocompatible

" disable splash
set shortmess+=I

" leader
let mapleader = "\<Space>"
nnoremap <Space> <Nop>

" Hide Toolbar
if has("gui_running")
    set guioptions=egmrt
    set guifont=Droid\ Sans\ Mono\ for \Powerline:h12
endif

" Dictionary
set dictionary+=/usr/share/dict/words

" Vundle
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

Bundle 'gmarik/vundle'

" Search
Bundle 'scrooloose/nerdtree.git'
Bundle 'tmhedberg/matchit.git'
Bundle 'Shougo/unite.vim.git'
Bundle 'majutsushi/tagbar'
Bundle 'vim-scripts/ZoomWin'
Bundle 't9md/vim-unite-ack'
Bundle 'ujihisa/unite-colorscheme'
Bundle 'osyo-manga/unite-quickfix'

" Speed
Bundle 'Raimondi/delimitMate.git'
Bundle 'tpope/vim-surround.git'
Bundle 'godlygeek/tabular.git'
Bundle 'jayflo/vim-skip'
Bundle 'tpope/vim-dispatch'
Bundle 'mhinz/vim-tmuxify'
Bundle 'tComment'
" Bundle 'Valloric/YouCompleteMe.git'

" Bundle 'jpalardy/vim-slime.git'
" Bundle 'junegunn/vim-easy-align'
" Bundle 'AndrewRadev/switch.vim'

" Visual
Bundle 'chriskempson/tomorrow-theme.git', { 'rtp': 'vim/' }
Bundle 'bling/vim-airline'
Bundle 'itchyny/calendar.vim'
Bundle 'tpope/vim-fugitive.git'
Bundle 'nathanaelkane/vim-indent-guides'

" Syntax
Bundle 'groenewege/vim-less.git'
Bundle 'digitaltoad/vim-jade.git'
Bundle 'pangloss/vim-javascript.git'
Bundle 'wting/rust.vim.git'
Bundle 'hylang/vim-hy.git'
Bundle 'findango/mdxdotvim'
Bundle 'JuliaLang/julia-vim'
" Bundle 'davidhalter/jedi-vim'
Bundle 'ciaranm/detectindent.git'

" Go
Bundle 'Blackrush/vim-gocode'
Bundle 'dgryski/vim-godef.git'

filetype plugin indent on
set backspace=indent,eol,start

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
command! W write 
nnoremap Q <nop>
" imap <C-[> <nop>

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

" Nerd Tree
map <Leader>n :NERDTreeToggle<CR>

" Unite
call unite#filters#matcher_default#use(['matcher_fuzzy'])
let g:unite_source_history_yank_enable = 1
let g:unite_source_grep_command = 'ag'

map <expr> <C-@> ':Unite -start-insert -toggle buffer tab file_rec<CR>'

map <Leader>uf :Unite -toggle -start-insert file_rec<CR>
map <Leader>ub :Unite -toggle -start-insert buffer<CR>
map <Leader>ua :Unite -auto-preview -auto-highlight ack<CR>
map <Leader>uy :Unite -toggle history/yank<CR>
map <Leader>uq :Unite -toggle quickfix<CR>
map <Leader>uc :Unite colorscheme<CR>
map <Leader>ux :Unite command<CR>
map <Leader>ut :Unite -toggle -start-insert tab<CR>

" Tabularize
command! -nargs=1 -range TabFirst exec <line1> . ',' . <line2> . 'Tabularize /^[^' . escape(<q-args>, '\^$.[?*~') . ']*\zs' . escape(<q-args>, '\^$.[?*~')
command! -nargs=1 -range Tab exec <line1> . ',' . <line2> . 'Tabularize /' . escape(<q-args>, '\^$.[?*~') 
map <Leader>t :TabFirst 

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

" toggle line numbers
nnoremap <Leader>l :set norelativenumber!<CR>

" faster pane switching
nnoremap <C-h> <C-w>h
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-l> <C-w>l

" GoDef
let g:godef_split=0
let g:godef_same_file_in_same_window=1

" Calendar
nmap <expr> <F9> &ft ==# 'calendar' ? "\<Plug>(calendar_exit)" : ":\<C-u>Calendar\<CR>"

" Run :make
nmap <F5> :make<CR>

" Tagbar
nmap <F8> :TagbarToggle<CR>
let g:tagbar_type_go = {
    \ 'ctagstype' : 'go',
    \ 'kinds'     : [
        \ 'p:package',
        \ 'i:imports:1',
        \ 'c:constants',
        \ 'v:variables',
        \ 't:types',
        \ 'n:interfaces',
        \ 'w:fields',
        \ 'e:embedded',
        \ 'm:methods',
        \ 'r:constructor',
        \ 'f:functions'
    \ ],
    \ 'sro' : '.',
    \ 'kind2scope' : {
        \ 't' : 'ctype',
        \ 'n' : 'ntype'
    \ },
    \ 'scope2kind' : {
        \ 'ctype' : 't',
        \ 'ntype' : 'n'
    \ },
    \ 'ctagsbin'  : 'gotags',
    \ 'ctagsargs' : '-sort -silent'
\ }

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

" Tmuxify

let g:tmuxify_map_prefix = '<leader>m'
