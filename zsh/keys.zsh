#!/bin/zsh

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in insert mode.
bindkey -M viins -rp '^['
bindkey -M viins '^[[3~' vi-cmd-mode
bindkey -M viins '^[[A' up-line-or-history
bindkey -M viins '^[[B' down-line-or-history
bindkey -M viins '^[[C' forward-char
bindkey -M viins '^[[D' backward-char

bindkey -M vicmd '^[[3~' beep
bindkey -M vicmd j backward-char
bindkey -M vicmd k down-line-or-history
bindkey -M vicmd l up-line-or-history
bindkey -M vicmd \; forward-char

bindkey -M vicmd \' vi-repeat-find

# Bindings in command mode.
bindkey -M vicmd 'u' undo
bindkey -M vicmd 'U' redo
