call plug#begin(stdpath('data') . '/plugged')
Plug 'tpope/vim-sensible'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'Xuyuanp/nerdtree-git-plugin'
Plug 'airblade/vim-gitgutter'
Plug 'kien/ctrlp.vim'
Plug 'tpope/vim-fugitive'
Plug 'scrooloose/syntastic'
Plug 'nathanaelkane/vim-indent-guides'
Plug 'majutsushi/tagbar'
Plug 'nvie/vim-flake8'
" Plug 'Valloric/YouCompleteMe'
call plug#end()

" Use comma as leader for quick custom mappings
let mapleader = ","

set list listchars=tab:▷⋅,trail:⋅,nbsp:⋅ " Visualize whitespace characters
set termguicolors " Enable true-color UI
" set clipboard=unnamedplus " Share registers with the system clipboard
set hidden " Allow switching buffers without saving
set splitbelow " Open horizontal splits below the current window
set splitright " Open vertical splits to the right
set wildmode=longest:full,full " Provide a friendlier completion cycle
set cursorline " Highlight the current line for focus

" NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif
nnoremap <leader>n :NERDTreeToggle<CR> " Quickly toggle NERDTree visibility

" NERDTree will ignore file that match regular expression
let NERDTreeIgnore = ['\.swp','\.pyc$']

" NERDTree will show hidden files
let NERDTreeShowHidden=1

" automatically populate the g:airline_symbols dictionary with the powerline symbols
" let g:airline_powerline_fonts = 1

" Automatically displays all buffers when there's only one tab open.
let g:airline#extensions#tabline#enabled = 1

" Straight tabs
let g:airline#extensions#tabline#left_sep = ' '
let g:airline#extensions#tabline#left_alt_sep = '|'

" airline theme
let g:airline_theme='serene'

" get rid of mode indicator (redudent with airline)
set noshowmode

" Built-in search configuration
set hlsearch " Highlight search results
set incsearch " Incremental search

" Disable line number by default
set nonumber " Start with a clean gutter

" Tabs
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab " Keep literal 4-space indentation without converting tabs

" Make searching less sucky
set ignorecase " Case-insensitive search by default
set smartcase " Restore sensitivity when the query has uppercase

" Shows all open buffers and their number
nnoremap <F5> :buffers<CR>:buffer<Space> " List and hop to buffers

" Don't use Ex mode, use Q for formatting
map Q gq " Use Q for formatting instead of Ex mode

" In many terminal emulators the mouse works just fine why not use it
if has('mouse')
  set mouse=a " Enable mouse support when available
endif

" Function to trim trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l,c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces() " Auto-trim trailing whitespace on save

augroup nerdtree_auto_quit
    autocmd!
    autocmd BufEnter * if winnr('$') == 1 && exists('t:NERDTreeBufName') && bufnr('%') == t:NERDTreeBufName | quit | endif " Exit Vim if only NERDTree remains
augroup END

