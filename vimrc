syntax enable
colorscheme sfiera

set ruler
set showcmd
set backspace=2
set nocompatible

filetype plugin indent on
set tabstop=4
set softtabstop=0
set shiftwidth=4
set nosmarttab
set expandtab
set autoindent
set cindent
set cino=g0,:0

set encoding=utf-8
set termencoding=utf-8

autocmd BufNewFile,BufRead .*Portfile setf tcl

" Stems the given file name, removing the extension as well as any of the
" possible suffices "_test", "_unittest", or "-inl"
function StemFile(fname)
  let pattern = '\(\([_-]\(unit\)\?test\)\?\(-inl\)\?\)$'
  return substitute(fnamemodify(a:fname, ":r"), pattern, "", "")
endfunction

" This function takes the stem of the current file, then globs for other files
" with the given stem and chooses the next one in sequence (if diff is +1) or
" the previous (if diff is -1).
"
" If "public" or "internal" appears in the absolute path, then the glob
" additionally considers both permutations of the path in which "public" and
" "internal" appear.
function MoveFile(diff)
  let fname = expand("%:p")  " Absolute path of current file
  let stem = StemFile(fname)
  if stem =~ "/public/" || stem =~ "/internal/"
    " If we are in a public or internal directory, glob against both
    " directories.
    let stem1 = substitute(stem, "/public/", "/internal/", "")
    let stem2 = substitute(stem1, "/internal/", "/public/", "")
    let glob = split((glob(stem1 . "*") . "\n" . glob(stem2 . "*")), "\n")
    let filter = 'StemFile(v:val) == stem1 || StemFile(v:val) == stem2'
  else
    " Else just glob against the one.
    let glob = split(glob(stem . "*"), "\n")
    let filter = 'StemFile(v:val) == stem'
  endif
  " It's possible that the glob matches files with different stems (e.g. foo.h
  " and foobar.h); filter them out.
  let glob = filter(copy(glob), filter)
  " Cycle through the list of candidates until we find the current file, then
  " pick the next one.
  let current = 0
  for g in glob
    if g == fname
      " Return the file name as a relative path.
      let file = glob[(current + a:diff) % len(glob)]
      return fnamemodify(file, ":.")
    else
      let current = current + 1
    endif
  endfor
endfunction

" Correct some "incorrect" mappings
map Y y$
map S ch

nmap ` :e <C-R>=MoveFile(+1)<CR><CR>
nmap ~ :e <C-R>=MoveFile(-1)<CR><CR>

command Trim :%s/ \+$//

source ~/.vimrc.folding
source ~/.vimrc.profiles
