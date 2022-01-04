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
Plug 'haya14busa/incsearch.vim'
Plug 'nvie/vim-flake8'
" Plug 'Valloric/YouCompleteMe'
call plug#end()

set list listchars=tab:▷⋅,trail:⋅,nbsp:⋅

" NERDTree automatically when vim starts up if no files were specified
autocmd StdinReadPre * let s:std_in=1
autocmd VimEnter * if argc() == 0 && !exists("s:std_in") | NERDTree | endif

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

" incsearch.vim
map /  <Plug>(incsearch-forward)
map ?  <Plug>(incsearch-backward)
map g/ <Plug>(incsearch-stay)
" :h g:incsearch#auto_nohlsearch
set hlsearch
let g:incsearch#auto_nohlsearch = 1
map n  <Plug>(incsearch-nohl-n)
map N  <Plug>(incsearch-nohl-N)
map *  <Plug>(incsearch-nohl-*)
map #  <Plug>(incsearch-nohl-#)
map g* <Plug>(incsearch-nohl-g*)
map g# <Plug>(incsearch-nohl-g#)
augroup incsearch-keymap
    autocmd!
    autocmd VimEnter * call s:incsearch_keymap()
augroup END
function! s:incsearch_keymap()
    " Tab to the next match
    IncSearchNoreMap <Right> <Over>(incsearch-next)
    " Shift-Tab to the previous match
    IncSearchNoreMap <Left>  <Over>(incsearch-prev)
endfunction

" Disable line number by default
set nonumber

" Tabs
set tabstop=4 softtabstop=4 shiftwidth=4 noexpandtab

" Make searching less sucky
set hlsearch
set ignorecase
set smartcase

" Shows all open buffers and their number
nnoremap <F5> :buffers<CR>:buffer<Space>

" Don't use Ex mode, use Q for formatting
map Q gq

" In many terminal emulators the mouse works just fine why not use it
if has('mouse')
  set mouse=a
endif

" Function to trim trailing whitespace on save
fun! <SID>StripTrailingWhitespaces()
  let l = line(".")
  let c = col(".")
  %s/\s\+$//e
  call cursor(l,c)
endfun
autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

