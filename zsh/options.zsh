#!/bin/zsh

# Completion
setopt AUTO_LIST
setopt COMPLETE_ALIASES
setopt COMPLETE_IN_WORD

# History
HISTFILE=~/.zsh_history
HISTSIZE=1000
SAVEHIST=1000
setopt APPEND_HISTORY
setopt EXTENDED_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS
setopt INC_APPEND_HISTORY
setopt SHARE_HISTORY

# Input/Output
setopt CORRECT
setopt PRINT_EXIT_VALUE

# Job Control
setopt NO_BG_NICE

# Prompting
setopt PROMPT_SP
setopt PROMPT_SUBST
