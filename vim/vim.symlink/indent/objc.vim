function! GetObjCIndent()
    let theIndent = cindent(v:lnum)

    let prev_line = getline(v:lnum - 1)
    let cur_line = getline(v:lnum)
        
    if prev_line !~# ":" || cur_line !~# ":"
        return theIndent
    endif
     
    if prev_line !~# ";" && prev_line !~# "{"
        let prev_colon_pos = s:GetWidth(prev_line, ":")
        let delta = s:GetWidth(cur_line, ":") - s:LeadingWhiteSpace(cur_line)
        let theIndent = prev_colon_pos - delta
    endif
        
    return theIndent
endfunction
