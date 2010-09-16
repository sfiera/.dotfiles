#!/bin/zsh

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in insert mode.
bindkey -M viins -rp '^['
bindkey -M viins '^[[3~' delete-char
bindkey -M viins '^[[A' up-line-or-history
bindkey -M viins '^[[B' down-line-or-history
bindkey -M viins '^[[C' forward-char
bindkey -M viins '^[[D' backward-char

# Bindings in command mode.
bindkey -M vicmd 'u' undo
