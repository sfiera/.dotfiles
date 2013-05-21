set background=dark
hi clear
if exists("syntax_on")
  syntax reset
endif
let g:colors_name = "sfiera"

hi Normal                           guifg=#cccccc
hi Normal                           guibg=#141414
hi NonText      ctermfg=black       guifg=black
hi NonText      ctermbg=black       guibg=black
hi ColorColumn  ctermbg=black       guibg=black
hi Comment      ctermfg=10          guifg=#008700
hi Constant     ctermfg=13          guifg=#00af87
hi Identifier   ctermfg=4           guifg=#005fd7
hi Preproc      ctermfg=142         guifg=#afaf00
hi Statement    ctermfg=4           guifg=#5f87ff
hi Type         ctermfg=5           guifg=#d75fff
hi Special      ctermfg=99          guifg=#875fff
hi Underlined   ctermfg=darkcyan    guifg=darkcyan
hi Underlined   cterm=underline     gui=underline
hi! link Label Statement

hi ErrorMsg     ctermfg=red
hi ErrorMsg     ctermbg=white
hi WarningMsg   ctermfg=cyan
hi ModeMsg      ctermfg=blue
hi MoreMsg      ctermfg=yellow
hi Error        ctermfg=red
hi Error        ctermbg=white

hi Todo         ctermfg=142
hi Todo         ctermbg=none
hi Todo         cterm=underline     gui=underline
hi Cursor       ctermfg=black
hi Cursor       ctermbg=white
hi LineNr       ctermfg=Magenta
hi title        cterm=bold          gui=bold

hi StatusLineNC ctermfg=black
hi StatusLineNC ctermbg=blue
hi StatusLine   ctermfg=cyan
hi StatusLine   ctermbg=blue

hi label        ctermfg=blue
hi operator     ctermfg=blue
hi clear Visual
hi Visual       ctermbg=10          guibg=#5fafd7

hi DiffChange   ctermbg=Green
hi DiffChange   ctermfg=black
hi DiffText     ctermbg=lightGreen
hi DiffText     ctermfg=black
hi DiffAdd      ctermbg=blue
hi DiffAdd      ctermfg=black
hi DiffDelete   ctermbg=cyan
hi DiffDelete   ctermfg=black

hi Folded       ctermfg=4           guifg=#121212
hi Folded       ctermbg=none        guibg=none
hi FoldColumn   ctermbg=gray
hi FoldColumn   ctermfg=black
hi cIf0         ctermfg=gray

hi Ignore       ctermfg=darkgray

hi CursorLine   cterm=none          gui=none
hi CursorLine   ctermbg=black       guibg=#1b1b1b
hi IncSearch    cterm=underline
hi IncSearch    ctermfg=none
hi IncSearch    ctermbg=none
hi Search       cterm=underline
hi Search       ctermfg=none
hi Search       ctermbg=none
hi StatusLine   cterm=none          gui=none
hi StatusLine   ctermbg=14          guibg=#5f5f87
hi StatusLine   ctermfg=0           guifg=#121212
