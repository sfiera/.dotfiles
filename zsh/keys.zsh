#!/bin/zsh

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in edit mode.
bindkey -M main '^[[3~' delete-char
bindkey -M main '^[[A' up-line-or-history
bindkey -M main '^[[B' down-line-or-history
bindkey -M main '^[[C' forward-char
bindkey -M main '^[[D' backward-char

# Bindings in command mode.
bindkey -M vicmd 'u' undo
