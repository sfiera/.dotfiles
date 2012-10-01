#!/bin/zsh

MACHINE=${MACHINE-%m}

PS_COLOR=${PS_COLOR-142}
DIRTY_COLOR=${DIRTY_COLOR-167}
STAGE_COLOR=${STAGE_COLOR-185}
CLEAN_COLOR=${CLEAN_COLOR-70}
DIM_COLOR=${DIM_COLOR-239}

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]] colors

function git_branch {
    local GITREF
    if GITREF=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null); then
        echo ${GITREF#refs/heads/}
    else
        GITREF=$(/usr/bin/git rev-parse HEAD)
        echo "(${GITREF[0,7]})"
    fi
}

function git_color {
    local COLOR
    COLOR=$CLEAN_COLOR
    /usr/bin/git status --porcelain 2>/dev/null | while read LINE; do
        COLOR=$STAGE_COLOR
        if [[ "${LINE[2]}" != " " ]]; then
            COLOR=$DIRTY_COLOR
            break
        fi
    done
    echo $COLOR
}

function tint_fg {
    local START=
    if [[ $1 == -b ]]; then
        START="$START%{\e[1m%}"; shift
    fi
    local COLOR=$1; shift
    local START="$START%{\e[38;05;${COLOR}m%}"
    local RESET="%{\e[0m%}"
    echo "$START$*$RESET"
}

function tint_bg {
    local COLOR=$1; shift
    local START="%{\e[48;05;${COLOR}m%}"
    local RESET="%{\e[0m%}"
    echo "$START$*$RESET"
}

PS1_PATH=
function set_prompt {
    local NEWLINE="
"
    local HERE="%~"
    HERE="${(%)HERE}"

    case $USER in
        root|sfiera|chpickel)   local LOCATION="$MACHINE" ;;
        *)                      local LOCATION="$USER@$MACHINE" ;;
    esac
    PS1="$(tint_fg -b $PS_COLOR $LOCATION)"

    if [[ $1 == fast ]]; then
        # Reuse PS1_PATH
    elif /usr/bin/git rev-parse --show-toplevel >/dev/null 2>/dev/null; then
        GIT_PREFIX=$(/usr/bin/git rev-parse --show-prefix)
        GIT_PREFIX=${GIT_PREFIX%/}
        GIT_TOPLEVEL=${HERE%${GIT_PREFIX}}
        if [[ ( $GIT_TOPLEVEL != $HERE ) || -z $GIT_PREFIX ]]; then
            PS1_PATH="$(tint_fg $DIM_COLOR $GIT_TOPLEVEL)$GIT_PREFIX"
        else
            PS1_PATH="$HERE"
        fi
        PS1_PATH="$PS1_PATH:$(tint_fg -b $(git_color) $(git_branch))"
    else
        PS1_PATH="$HERE"
    fi
    PS1="$PS1:$PS1_PATH"

    if [[ $KEYMAP == vicmd ]]; then
        PS1="$PS1$NEWLINE$(tint_bg $PS_COLOR $(tint_fg -b 0 %#)) "
    else
        PS1="$PS1$NEWLINE$(tint_fg -b $PS_COLOR %#) "
    fi
}

precmd() {
    echo
    set_prompt full
}

zle-keymap-select() {
    if [[ "$SUPPRESS_ZLE_KEYMAP_SELECT" != y ]]; then
        set_prompt fast
        zle reset-prompt
    fi
}
zle -N zle-keymap-select

update-prompt() {
    set_prompt full
    zle reset-prompt
}
zle -N update-prompt
