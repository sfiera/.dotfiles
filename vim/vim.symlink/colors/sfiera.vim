set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "sfiera"
hi NonText      ctermfg=lightMagenta
hi comment      ctermfg=darkgreen
hi constant     ctermfg=darkcyan
hi identifier   ctermfg=darkmagenta
hi statement    ctermfg=blue
hi preproc      ctermfg=yellow
hi type         ctermfg=blue
hi special      ctermfg=darkMagenta
hi Underlined   ctermfg=darkcyan
hi Underlined   cterm=underline

hi ErrorMsg     ctermfg=red         ctermbg=white
hi WarningMsg   ctermfg=cyan
hi ModeMsg      ctermfg=blue
hi MoreMsg      ctermfg=yellow
hi Error        ctermfg=red         ctermbg=white

hi Todo         ctermfg=black       ctermbg=Yellow
hi Cursor       ctermfg=black       ctermbg=white
hi Search       ctermfg=black       ctermbg=Yellow
hi IncSearch    ctermfg=black       ctermbg=Yellow
hi LineNr       ctermfg=Magenta
hi title        cterm=bold

hi StatusLineNC ctermfg=black       ctermbg=blue
hi StatusLine   ctermfg=cyan        ctermbg=blue

hi label        ctermfg=blue
hi operator     ctermfg=blue
hi clear Visual
hi Visual       term=reverse
hi Visual       ctermfg=black       ctermbg=Cyan

hi DiffChange   ctermbg=Green       ctermfg=black
hi DiffText     ctermbg=lightGreen  ctermfg=black
hi DiffAdd      ctermbg=blue        ctermfg=black
hi DiffDelete   ctermbg=cyan        ctermfg=black

hi Folded       ctermbg=cyan        ctermfg=black
hi FoldColumn   ctermbg=gray        ctermfg=black
hi cIf0         ctermfg=gray

hi Ignore       ctermfg=darkgray
