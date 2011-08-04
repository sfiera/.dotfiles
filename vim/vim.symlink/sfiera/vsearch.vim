vnoremap <silent>m <ESC>:call VisualSearch('/')<CR>/<CR>
vnoremap <silent>M <ESC>:call VisualSearch('?')<CR>?<CR>

function! VisualSearch(dirrection)
    let l:register=@@
    normal! gvy
    let l:search=escape(@@, '$.*/\[]')
    if a:dirrection=='/'
        execute 'normal! /'.l:search
    else
        execute 'normal! ?'.l:search
    endif
    let @/=l:search
    normal! gV
    let @@=l:register
endfunction
