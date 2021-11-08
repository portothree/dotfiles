packadd! dracula
colorscheme dracula

set clipboard=unnamedplus
set number
set tabstop=4
set shiftwidth=4
set background=dark
set t_Co=256
set autoindent
set nocp

au BufNewFile,BufRead *.ldg,*.ledger setf ledger | comp ledger

filetype plugin indent on
syntax on 
