#!/bin/zsh

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in insert mode.
bindkey -M viins -rp '^['
bindkey -M viins '^[' vi-cmd-mode

for MAP in viins vicmd; do
    bindkey -M $MAP '^[[A' noop
    bindkey -M $MAP '^[[B' noop
    bindkey -M $MAP '^[[C' noop
    bindkey -M $MAP '^[[D' noop
done

bindkey -M vicmd '^[OA' noop
bindkey -M vicmd '^[OB' noop
bindkey -M vicmd '^[OC' noop
bindkey -M vicmd '^[OD' noop
bindkey -M vicmd '^[OF' noop
bindkey -M vicmd '^[OH' noop
bindkey -M vicmd '^[[2~' noop
bindkey -M vicmd '^[[3~' noop

bindkey -M vicmd j backward-char
bindkey -M vicmd k down-line-or-history
bindkey -M vicmd l up-line-or-history
bindkey -M vicmd \; forward-char

bindkey -M vicmd J vi-beginning-of-line
bindkey -M vicmd K history-beginning-search-forward-inclusive
bindkey -M vicmd L history-beginning-search-backward-inclusive
bindkey -M vicmd : vi-end-of-line

bindkey -M vicmd s vi-repeat-find
bindkey -M vicmd S vi-rev-repeat-find
bindkey -M vicmd ' ' vi-repeat-change

bindkey -M vicmd u undo
bindkey -M vicmd U redo
bindkey -M vicmd m vi-goto-mark
bindkey -M vicmd M vi-set-mark

bindkey -M vicmd -s G g
bindkey -M vicmd gh vi-match-bracket

bindkey "^[[200~" paste-mode
bindkey -M vicmd "^[[200~" paste-mode
bindkey -N paste
bindkey -M paste -R "^@-^?" self-insert
bindkey -M paste "^[[201~" vi-add-next

# New ZLE widgets

noop() {}
zle -N noop

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

paste-mode() {
    zle -K paste
}
zle -N paste-mode
