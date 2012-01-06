nnoremap <silent>s :set opfunc=ForwardsVisualSearch<CR>g@
nnoremap <silent>S :set opfunc=BackwardsVisualSearch<CR>g@
vnoremap <silent>s :<C-U>call ForwardsVisualSearch(visualmode(), '/')<CR>/<CR>
vnoremap <silent>S :<C-U>call BackwardsVisualSearch(visualmode(), '?')<CR>?<CR>

function! VisualSearch(visual, type, direction)
    let saved_selection = &selection
    let &selection = "inclusive"
    let saved_register=@@

    if a:visual  " Invoked from visual mode
        silent exe "normal! `<" . a:type . "`>y"
    elseif a:type == "line"
        silent exe "normal! '[V']y"
    elseif a:type == "block"
        silent exe "normal! `[<C-V>`]y"
    else
        silent exe "normal! `[v`]y"
    endif

    let search=escape(@@, '$.*/\[]<>')
    echo a:direction
    echo l:search
    if a:direction=='/'
        execute 'normal! /' . l:search
    else
        execute 'normal! ?' . l:search
    endif
    let @/=l:search

    let @@=l:saved_register
    let &selection = saved_selection
endfunction

function! ForwardsVisualSearch(type, ...)
    call VisualSearch(a:0, a:type, '/')
endfunction

function! BackwardsVisualSearch(type, ...)
    call VisualSearch(a:0, a:type, '?')
endfunction
