" -*- mode: vim; tab-width: 4; indent-tabs-mode: nil; fill-column: 99 -*-
"
" ~sfiera/.vim/colors/sfiera.vim
" Brief: sfiera's colors
" Maintainer: Chris Pickel <sfiera@sfzmail.com>
"
" Preamble {{{
set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "sfiera"
" }}}
" Code {{{
hi Constant     ctermfg=13          guifg=#00af87
hi Identifier   ctermfg=4           guifg=#005fd7
hi Preproc      ctermfg=142         guifg=#afaf00
hi Statement    ctermfg=4           guifg=#5f87ff
hi Type         ctermfg=5           guifg=#d75fff
hi Special      ctermfg=99          guifg=#875fff
hi Underlined   ctermfg=darkcyan    guifg=darkcyan
hi Underlined   cterm=underline     gui=underline
hi! link Label Statement

hi label        ctermfg=blue
hi operator     ctermfg=blue

hi title        cterm=bold          gui=bold
" }}}
" Comments {{{
hi Comment      ctermfg=10          guifg=#008700
hi Todo         ctermbg=none    ctermfg=142     cterm=underline
" }}}
" Errors {{{
hi ErrorMsg     ctermfg=red
hi ErrorMsg     ctermbg=white
hi WarningMsg   ctermfg=cyan
hi ModeMsg      ctermfg=blue
hi MoreMsg      ctermfg=yellow
hi Error        ctermfg=red
hi Error        ctermbg=white
" }}}
" vimdiff {{{
hi DiffChange   ctermbg=Green
hi DiffChange   ctermfg=black
hi DiffText     ctermbg=lightGreen
hi DiffText     ctermfg=black
hi DiffAdd      ctermbg=blue
hi DiffAdd      ctermfg=black
hi DiffDelete   ctermbg=cyan
hi DiffDelete   ctermfg=black
" }}}
" Interface {{{
hi NonText      ctermfg=10      ctermbg=8
hi ColorColumn  ctermbg=232

hi StatusLine   ctermbg=14      ctermfg=0       cterm=none
hi StatusLineNC ctermbg=blue    ctermfg=black
hi CursorLine   ctermbg=black                   cterm=none
hi TablineSel   ctermbg=0       ctermfg=3       cterm=none
hi TablineFill  ctermbg=232     ctermfg=10      cterm=none
hi Tabline      ctermbg=232     ctermfg=10      cterm=none

hi Visual       ctermbg=10
hi IncSearch    ctermbg=none    ctermfg=none    cterm=underline
hi Search       ctermbg=none    ctermfg=none    cterm=underline
hi Cursor       ctermfg=black   ctermbg=white
hi LineNr       ctermfg=magenta
hi MatchParen   ctermbg=0       ctermfg=15      cterm=bold
" }}}
" Folds {{{
hi Folded       ctermbg=none    ctermfg=4     
hi FoldColumn   ctermbg=gray    ctermfg=black
hi! link cIf0 Comment
" }}}

hi SyntasticWarning ctermbg=0 cterm=underline
hi SyntasticError ctermbg=0 ctermfg=1 cterm=underline
