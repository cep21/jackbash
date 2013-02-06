set nocompatible
filetype off
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()
Bundle 'gmarik/vundle'
Bundle 'tpope/vim-fugitive'
Bundle 'wincent/Command-T'
Bundle 'Valloric/YouCompleteMe'
Bundle 'taglist.vim'
filetype plugin indent on

map ; :CommandT<CR>

source ~/.bash/group/vimrc
set tags=tags;/

let g:syntastic_python_checker = 'flake8'
let g:syntastic_enable_highlighting=1
" On by default, turn it off for html
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['html'] }
let g:syntastic_check_on_open=1
" Well, this is sad!
let g:syntastic_python_checker_args = '--ignore=E501'
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
set incsearch
set hlsearch
match OverLength /\%81v./
set cscopetag

" http://stackoverflow.com/questions/526858/how-do-i-make-vim-do-normal-bash-like-tab-completion-for-file-names
set wildmode=longest,list,full
set wildmenu
" http://stackoverflow.com/questions/3686841/vim-case-insensitive-filename-completion
if exists("&wildignorecase")
    set wildignorecase
endif

" https://github.com/apache/thrift/blob/master/contrib/thrift.vim
au BufRead,BufNewFile *.thrift set filetype=thrift
au! Syntax thrift source ~/.bash/config/thrift.vim
