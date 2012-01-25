set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "sfiera"
hi NonText      ctermfg=black       ctermbg=black
hi Comment      ctermfg=28
hi Constant     ctermfg=36
hi Identifier   ctermfg=26
hi Preproc      ctermfg=142
hi Statement    ctermfg=69
hi Type         ctermfg=171
hi Special      ctermfg=99
hi Underlined   ctermfg=darkcyan
hi Underlined   cterm=underline
hi! link Label Statement

hi ErrorMsg     ctermfg=red         ctermbg=white
hi WarningMsg   ctermfg=cyan
hi ModeMsg      ctermfg=blue
hi MoreMsg      ctermfg=yellow
hi Error        ctermfg=red         ctermbg=white

hi Todo         ctermfg=black       ctermbg=221
hi Cursor       ctermfg=black       ctermbg=white
hi LineNr       ctermfg=Magenta
hi title        cterm=bold

hi StatusLineNC ctermfg=black       ctermbg=blue
hi StatusLine   ctermfg=cyan        ctermbg=blue

hi label        ctermfg=blue
hi operator     ctermfg=blue
hi clear Visual
hi Visual       term=reverse
hi Visual       ctermfg=black       ctermbg=74

hi DiffChange   ctermbg=Green       ctermfg=black
hi DiffText     ctermbg=lightGreen  ctermfg=black
hi DiffAdd      ctermbg=blue        ctermfg=black
hi DiffDelete   ctermbg=cyan        ctermfg=black

hi Folded       ctermbg=60          ctermfg=233
hi FoldColumn   ctermbg=gray        ctermfg=black
hi cIf0         ctermfg=gray

hi Ignore       ctermfg=darkgray

hi LineNr       ctermbg=none        ctermfg=60
hi CursorLine   cterm=none          ctermbg=235
hi IncSearch    cterm=underline     ctermfg=none        ctermbg=none
hi Search       cterm=underline     ctermfg=none        ctermbg=none
hi StatusLine   cterm=none          ctermbg=60          ctermfg=233
