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
    au BufRead,BufEnter */chrome/*/*ntp*/*.{cc,c,mm,m,h} AutoFormatBuffer clang-format
augroup END

augroup procyon
    au BufRead,BufEnter *.pn AutoFormatBuffer pnfmt
augroup END

augroup antares
    au BufRead,BufEnter */antares*/*.{cpp,hpp,m,c,h} AutoFormatBuffer clang-format
    au BufRead,BufEnter */libsfz*/*.{cpp,hpp,m,c,h} AutoFormatBuffer clang-format
    au BufRead,BufEnter */rezin*/*.{cpp,hpp,m,c,h} AutoFormatBuffer clang-format
    au BufRead,BufEnter */procyon*/*.{cpp,hpp,m,c,h} AutoFormatBuffer clang-format
    au BufRead,BufEnter */antares*/*.py AutoFormatBuffer yapf
    au BufRead,BufEnter */qalb*/*.py AutoFormatBuffer yapf
    au BufRead,BufEnter */procyon*/*.py AutoFormatBuffer yapf
    au BufRead,BufEnter */.dotfiles*/*.py AutoFormatBuffer yapf
    au BufRead,BufEnter */procyon*/include/pn/* AutoFormatBuffer clang-format
    au BufRead,BufEnter */acrux/*.py AutoFormatBuffer yapf
augroup END
