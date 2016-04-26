filetype plugin indent on
set tabstop=4
if v:version >= 704
    set softtabstop=-1
    set shiftwidth=0
else
    set softtabstop=4
    set shiftwidth=4
endif
set nosmarttab
set expandtab
set autoindent
set cindent
set cinoptions=l1,N-s,(0,W2s
set textwidth=99

set encoding=utf-8
set termencoding=utf-8

augroup chromium
    au BufRead,BufEnter */chrome/*.{cc,h}  set ts=2 tw=80 cinoptions=l1,g1,h1,N-s,(0,W2s
    au BufRead,BufEnter */chrome/*.java    set tw=100
augroup END
