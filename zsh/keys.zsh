#!/bin/zsh

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in insert mode.
bindkey -M viins -rp '^['
bindkey -M viins '^[' vi-cmd-mode

for MAP in viins vicmd; do
    bindkey -M $MAP -r '^[[A'
    bindkey -M $MAP -r '^[[B'
    bindkey -M $MAP -r '^[[C'
    bindkey -M $MAP -r '^[[D'
done

bindkey -M vicmd '^[' update-prompt
bindkey -M vicmd -r '^[OA'
bindkey -M vicmd -r '^[OB'
bindkey -M vicmd -r '^[OC'
bindkey -M vicmd -r '^[OD'
bindkey -M vicmd -r '^[OF'
bindkey -M vicmd -r '^[OH'
bindkey -M vicmd -r '^[[2~'
bindkey -M vicmd -r '^[[3~'

bindkey -M vicmd j backward-char
bindkey -M vicmd k down-line-or-history
bindkey -M vicmd l up-line-or-history
bindkey -M vicmd \; forward-char

bindkey -M vicmd J vi-beginning-of-line
bindkey -M vicmd K history-beginning-search-forward-inclusive
bindkey -M vicmd L history-beginning-search-backward-inclusive
bindkey -M vicmd : vi-end-of-line

bindkey -M vicmd , vi-rev-repeat-find
bindkey -M vicmd . vi-repeat-find
bindkey -M vicmd \' vi-repeat-change

bindkey -M vicmd 'u' undo
bindkey -M vicmd 'U' redo

# New ZLE widgets

history-beginning-search-forward-inclusive() {
    SUPPRESS_ZLE_KEYMAP_SELECT=y
    zle vi-add-next
    zle history-beginning-search-forward
    zle vi-cmd-mode
    SUPPRESS_ZLE_KEYMAP_SELECT=n
}
zle -N history-beginning-search-forward-inclusive

history-beginning-search-backward-inclusive() {
    SUPPRESS_ZLE_KEYMAP_SELECT=y
    zle vi-add-next
    zle history-beginning-search-backward
    zle vi-cmd-mode
    SUPPRESS_ZLE_KEYMAP_SELECT=n
}
zle -N history-beginning-search-backward-inclusive
