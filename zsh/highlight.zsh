#!/bin/zsh

typeset -A ZSH_HIGHLIGHT_STYLES

ZSH_HIGHLIGHT_STYLES[unknown-token]='none'
ZSH_HIGHLIGHT_STYLES[builtin]='none'
ZSH_HIGHLIGHT_STYLES[command]='none'
ZSH_HIGHLIGHT_STYLES[function]='none'
ZSH_HIGHLIGHT_STYLES[arg0]='none'
ZSH_HIGHLIGHT_STYLES[reserved-word]='fg=4'
ZSH_HIGHLIGHT_STYLES[precommand]='fg=10'

ZSH_HIGHLIGHT_STYLES[single-hyphen-option]='fg=3'
ZSH_HIGHLIGHT_STYLES[double-hyphen-option]='fg=3'

ZSH_HIGHLIGHT_STYLES[single-quoted-argument]='fg=13'
ZSH_HIGHLIGHT_STYLES[double-quoted-argument]='fg=13'
ZSH_HIGHLIGHT_STYLES[dollar-quoted-argument]='fg=13'

ZSH_HIGHLIGHT_STYLES[dollar-double-quoted-argument]='fg=6'
ZSH_HIGHLIGHT_STYLES[back-double-quoted-argument]='fg=6'
ZSH_HIGHLIGHT_STYLES[back-dollar-quoted-argument]='fg=6'

ZSH_HIGHLIGHT_STYLES[globbing]='fg=4'
ZSH_HIGHLIGHT_STYLES[history-expansion]='fg=4'

ZSH_HIGHLIGHT_STYLES[commandseparator]='none'
ZSH_HIGHLIGHT_STYLES[redirection]='none'

ZSH_HIGHLIGHT_STYLES[back-quoted-argument]='fg=11'
