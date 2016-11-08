syn match gitcommitSummary "^.\{0,49\}[^.]"
            \ contained
            \ containedin=gitcommitFirstLine
            \ nextgroup=gitcommitOverflow
            \ contains=@Spell

hi def link gitcommitOverflow Error
