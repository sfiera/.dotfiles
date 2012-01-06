#!/bin/zsh

MACHINE=${MACHINE-%m}

PS_COLOR=${PS_COLOR-100}
DIRTY_COLOR=${DIRTY_COLOR-167}
CLEAN_COLOR=${CLEAN_COLOR-185}
DIM_COLOR=${DIM_COLOR-239}

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]] colors

function git_branch {
    local GITREF
    if GITREF=$(git symbolic-ref HEAD 2>/dev/null); then
        echo ${GITREF#refs/heads/}
    else
        GITREF=$(git rev-parse HEAD)
        echo "(${GITREF[0,7]})"
    fi
}

function git_dirty {
    local GITSTATUS
    GITSTATUS=$(git status 2>/dev/null | tail -n1)
    if [[ $GITSTATUS == "nothing to commit (working directory clean)" ]]; then
        return 1
    fi
}

function tint {
    local COLOR="%{\e[38;05;${1}m%}"
    local RESET="%{\e[38;05;m%}"
    shift
    echo "$COLOR$*$RESET"
}

function set_prompt {
    local NEWLINE="
"
    local HERE="%~"
    HERE="${(%)HERE}"

    case $USER in
        root|sfiera|chpickel)   local LOCATION="$MACHINE" ;;
        *)                      local LOCATION="$USER@$MACHINE" ;;
    esac
    PS1="$NEWLINE$(tint $PS_COLOR $LOCATION)"

    if git rev-parse --show-toplevel >/dev/null 2>/dev/null; then
        GIT_PREFIX=$(git rev-parse --show-prefix)
        GIT_PREFIX=${GIT_PREFIX%/}
        GIT_TOPLEVEL=${HERE%${GIT_PREFIX}}
        if [[ ( $GIT_TOPLEVEL != $HERE ) || -z $GIT_PREFIX ]]; then
            PS1="$PS1:$(tint $DIM_COLOR $GIT_TOPLEVEL)$GIT_PREFIX"
        else
            PS1="$PS1:$HERE"
        fi
        if git_dirty; then
            PS1="$PS1:$(tint $DIRTY_COLOR $(git_branch))"
        else
            PS1="$PS1:$(tint $CLEAN_COLOR $(git_branch))"
        fi
    else
        PS1="$PS1:$HERE"
    fi

    PS1="$PS1$NEWLINE$(tint $PS_COLOR %#) "
}

function precmd {
    set_prompt
}
