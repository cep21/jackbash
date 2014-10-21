" Setup for vundle
set nocompatible
filetype off
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()
" How I manage all my plugins
Plugin 'gmarik/vundle'
" Dockerfile syntax support
Plugin 'ekalinin/Dockerfile.vim'
" Git support (:Gstatus)
Plugin 'tpope/vim-fugitive'
" Gives me the left side highlighting
Plugin 'scrooloose/syntastic'
" Gives me ; to explore files
Plugin 'wincent/Command-T'
" Manage window sessions with SaveSession
" Bundle 'xolox/vim-session'
" Show possible tab completions while editting
" Bundle 'Valloric/YouCompleteMe'
" Explore tags (:TlistOpen)
Plugin 'taglist.vim'
" Rustlang syntastic checks
Plugin 'wting/rust.vim'
call vundle#end()
filetype plugin indent on
syntax on

" Supports Command-T as ;
map ; :CommandT<CR>

" Source company specific vim settings
if filereadable(glob("~/.bash/group/vimrc")) 
  source ~/.bash/group/vimrc
endif
" Allos recursive tags file searching
set tags=tags;/

let g:syntastic_python_checkers = ['flake8']
let g:syntastic_cpp_checkers = ['gcc']
let g:syntastic_enable_highlighting=1
" On by default, turn it off for html
let g:syntastic_mode_map = { 'mode': 'active',
                           \ 'active_filetypes': [],
                           \ 'passive_filetypes': ['html'] }
let g:syntastic_check_on_open=1
" Well, this is sad!
let g:syntastic_python_checker_args = '--ignore=E501'

" Highlight over 80 col as red
highlight OverLength ctermbg=red ctermfg=white guibg=#592929
set incsearch
set hlsearch
match OverLength /\%81v./
" Search cscope for ctrl + ]
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
autocmd FileType thrift :setlocal sw=2 ts=2 sts=2
au! Syntax thrift source ~/.bash/config/thrift.vim

" http://protobuf.googlecode.com/svn-history/r28/trunk/editors/proto.vim
augroup filetype
  au! BufRead,BufNewFile *.proto set filetype=proto
  autocmd FileType proto :setlocal sw=2 ts=2 sts=2
  au! Syntax proto source ~/.bash/config/proto.vim
augroup end
