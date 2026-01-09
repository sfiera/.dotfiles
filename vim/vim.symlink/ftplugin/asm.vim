syn clear asmComment
syn match asmComment    ";.*" contains=asmTodo,@Spell
syn match asmDirective  "#[A-Za-z][0-9A-Za-z-_]*"
setlocal cinkeys-=0#
setlocal indentkeys-=0#
