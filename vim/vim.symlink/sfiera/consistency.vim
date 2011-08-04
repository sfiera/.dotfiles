" Correct some "incorrect" mappings
nmap Y y$
vmap Y yy
nmap S ch
nmap cw dwi
nmap cW dWi
nmap U <C-R>

noremap H :call NewH()<CR>
noremap J :call NewJ()<CR>
noremap K :call NewK()<CR>
noremap L :call NewL()<CR>

function! NewH()
    let l:col = getpos(".")[2]
    normal! ^
    if getpos(".")[2] >= l:col
        normal! -
    endif
endfunction

function! NewJ()
    let l:lnum = getpos(".")[1]
    normal! L
    if getpos(".")[1] <= l:lnum
        normal! zzL
    endif
endfunction

function! NewK()
    let l:lnum = getpos(".")[1]
    normal! H
    if getpos(".")[1] >= l:lnum
        normal! zzH
    endif
endfunction

function! NewL()
    let l:col = getpos(".")[2]
    normal! $
    if getpos(".")[2] <= l:col
        normal! 2$
    endif
endfunction
