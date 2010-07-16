#!/bin/zsh

MACHINE=%m
PS_COLOR=${PS_COLOR-yellow}

git_branch() {
    local GITREF
    GITREF=$(git symbolic-ref HEAD 2>/dev/null) || return
    echo ${GITREF#refs/heads/}
}

git_dirty() {
    local GITSTATUS
    GITSTATUS=$(git status 2>/dev/null | tail -n1)
    if [[ $GITSTATUS == "nothing to commit (working directory clean)" ]]; then
        return 1
    fi
}

function tint {
    local COLOR="%B%F{$1}"
    local RESET="%b%f"
    shift
    echo "$COLOR$*$RESET"
}

function set_prompt {
    NEWLINE="
"

    case $USER in
        root|sfiera|chpickel)   local LOCATION="$MACHINE" ;;
        *)                      local LOCATION="$USER@$MACHINE" ;;
    esac
    PS1="$NEWLINE$(tint $PS_COLOR $LOCATION):%~"

    local GIT_BRANCH=$(git_branch)
    if [[ -n $GIT_BRANCH ]]; then
        if git_dirty; then
            PS1="$PS1:$(tint red $GIT_BRANCH)"
        else
            PS1="$PS1:$(tint yellow $GIT_BRANCH)"
        fi
    fi

    PS1="$PS1$NEWLINE$(tint $PS_COLOR %#) "
}

precmd() {
    set_prompt
}
