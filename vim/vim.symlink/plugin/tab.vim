"
" Tab alignment plugin.
" TODO: make repetition work, if that's actually possible
"
if !(has('python') || has('python3'))
    exit
endif

inoremap <expr> <Tab> InsertTab()

if has('python3')
    let s:python = "python3 << EOF"
else
    let s:python = "python << EOF"
endif
exec s:python
def InsertTab():
    if int(vim.eval("pumvisible()")):
        return r"\<C-N>"
    elif not int(vim.eval("&expandtab")):
        return r"\<Tab>"

    if hasattr(__builtins__, "xrange"):
        xrange = __builtins__.xrange
    else:
        xrange = __builtins__.range

    row, col = vim.current.window.cursor
    line = vim.current.line
    ins = col + len(line[col:]) - len(line[col:].lstrip(" "))
    before, after = line[:ins], line[ins:]
    shiftwidth = int(vim.eval("shiftwidth()"))

    width = None
    adjacent_lines = []
    for i in xrange(row - 2, -1, -1):
        if vim.current.buffer[i].strip():
            adjacent_lines.append(vim.current.buffer[i])
            break
    for i in xrange(row, len(vim.current.buffer)):
        if vim.current.buffer[i].strip():
            adjacent_lines.append(vim.current.buffer[i])
            break

    adjacent_stops = []
    for adj in adjacent_lines:
        while True:
            at = adj.rfind("  ") + 2
            if at == 1:
                break
            adjacent_stops.append(at)
            adj = adj[:at].rstrip(" ")
            if not adj:
                adjacent_stops.extend(xrange(shiftwidth, at, shiftwidth))
    try:
        width = min(stop for stop in adjacent_stops if stop > ins) - ins
    except ValueError:
        pass

    if width is None:
        if before.strip(" "):
            width = 1
        else:
            width = 1 + ((shiftwidth - ins - 1) % shiftwidth)

    if ins == col:
        return width * r"\<Space>"
    else:
        return (ins - col) * '\<Right>'
EOF

function! InsertTab()
exec s:python
vim.command('return "%s"' % InsertTab())
EOF
endfunction
