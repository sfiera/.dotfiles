#!/bin/zsh

MACHINE=${MACHINE-%m}
MACHINE=${(%)MACHINE}

typeset -A PS_COLORS
PS_COLORS=(
    durendal 2
    courtain 4
    florence 5
    hauteclaire 13
    joyeuse 13
    misericorde 6
    olifan 2
    baptism 6
    flamberge 1
    sauvagine 3
)

DIRTY_COLOR=${DIRTY_COLOR-1}
STAGE_COLOR=${STAGE_COLOR-142}
CLEAN_COLOR=${CLEAN_COLOR-2}
DIM_COLOR=${DIM_COLOR-10}

autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]] colors

function git_branch {
    local GITREF
    if GITREF=$(/usr/bin/git symbolic-ref --short HEAD 2>/dev/null); then
        echo $GITREF
    else
        echo "($(/usr/bin/git rev-parse --short HEAD))"
        return 1
    fi
}

function git_ahead {
    local GIT_BRANCH=$1
    local GIT_BEHIND GIT_AHEAD
    if ! /usr/bin/git rev-list --count --left-right $GIT_BRANCH@{upstream}...$GIT_BRANCH \
            2>/dev/null \
            | read GIT_BEHIND GIT_AHEAD; then
        return
    fi
    if [[ $GIT_AHEAD > 0 ]]; then
        echo -n $(tint $CLEAN_COLOR +$GIT_AHEAD)
    fi
    if [[ $GIT_BEHIND > 0 ]]; then
        echo -n $(tint $DIRTY_COLOR -$GIT_BEHIND)
    fi

    if GIT_UPLOAD_HASH=$(/usr/bin/git config --get "branch.$GIT_BRANCH.last-upload-hash"); then
        GIT_BRANCH_HASH=$(/usr/bin/git rev-parse $GIT_BRANCH)
        if [[ $GIT_UPLOAD_HASH == $GIT_BRANCH_HASH ]]; then
            echo -n $(tint $CLEAN_COLOR '^')
        else
            echo -n $(tint $STAGE_COLOR '*')
        fi
    fi
}

function git_color {
    local COLOR
    COLOR=$CLEAN_COLOR
    /usr/bin/git status --porcelain 2>/dev/null | while IFS= read LINE; do
        COLOR=$STAGE_COLOR
        if [[ "${LINE[2]}" != " " ]]; then
            COLOR=$DIRTY_COLOR
            break
        fi
    done
    echo $COLOR
}

function tint {
    local START=
    local BOLD=0
    local REVERSE=0
    while [[ $# > 0 ]]; do
        case $1 in
            -b) BOLD=1; shift ;;
            -r) REVERSE=1; shift ;;
            *) break ;;
        esac
    done
    local COLOR=$1; shift
    START="$START\e[0"
    if [[ $BOLD != 0 ]]; then
        START="${START};1"
    fi
    if [[ $REVERSE != 0 ]]; then
        START="${START};7"
    fi
    START="${START}m\e[38;5;${COLOR}m"
    local RESET="\e[0m"
    echo "%{$START%}$*%{$RESET%}"
}

ASYNC_PROC=0
PS1_PATH=
PS1_BRANCH=
PS1_FILE=~/.local/tmp/zsh/gitdata/$$
function set_prompt {
    local NEWLINE=$'\n'
    local PS1_HOST=""
    local PS1_CHAR=""
    local PS_COLOR="${PS_COLORS[$MACHINE]-3}"
    local HERE="%~"
    HERE="${(%)HERE}"

    # PS1_HOST
    case $USER in
        root|sfiera|chpickel)   local LOCATION="$MACHINE" ;;
        *)                      local LOCATION="$USER@$MACHINE" ;;
    esac
    PS1_HOST="$(tint -b $PS_COLOR $LOCATION)"

    # PS1_CHAR
    if [[ $KEYMAP == vicmd ]]; then
        PS1_CHAR="$(tint -r -b $PS_COLOR %#) "
    else
        PS1_CHAR="$(tint -b $PS_COLOR %#) "
    fi

    # PS1_PATH
    if [[ $1 == fast ]]; then
        # Reuse PS1_PATH and PS1_BRANCH
    elif /usr/bin/git rev-parse --show-toplevel >/dev/null 2>/dev/null; then
        local GIT_PREFIX=$(/usr/bin/git rev-parse --show-prefix)
        GIT_PREFIX=${GIT_PREFIX%/}
        local GIT_TOPLEVEL=${HERE%${GIT_PREFIX}}
        if [[ ( $GIT_TOPLEVEL != $HERE ) || -z $GIT_PREFIX ]]; then
            PS1_PATH="$(tint $DIM_COLOR $GIT_TOPLEVEL)$GIT_PREFIX"
        else
            PS1_PATH="$HERE"
        fi
        PS1_BRANCH=:$(git_branch)

        async() {
            local GIT_BRANCH
            mkdir -p $(dirname $PS1_FILE)
            if GIT_BRANCH=$(git_branch); then
                echo -n ":$(tint $(git_color) $GIT_BRANCH)$(git_ahead $GIT_BRANCH)" >$PS1_FILE
            else
                echo -n ":$(tint $(git_color) $GIT_BRANCH)" >$PS1_FILE
            fi
            kill -s USR1 $$
        }
        if [[ $ASYNC_PROC != 0 ]]; then
            kill -s HUP $ASYNC_PROC >/dev/null 2>&1
        fi
        async &!
        ASYNC_PROC=$!
    else
        PS1_BRANCH=
        PS1_PATH="$HERE"
    fi

    PS1="$PS1_HOST:$PS1_PATH$PS1_BRANCH$NEWLINE$PS1_CHAR"
}

TRAPUSR1() {
    PS1_BRANCH=$(cat $PS1_FILE)
    rm $PS1_FILE
    set_prompt fast
    ASYNC_PROC=0
    zle && zle reset-prompt
}

preexec() {
    if [[ $ASYNC_PROC != 0 ]]; then
        kill -s HUP $ASYNC_PROC >/dev/null 2>&1
        wait $ASYNC_PROC >/dev/null 2>&1
        ASYNC_PROC=0
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
    zle -R
}
zle -N zle-keymap-select

update-prompt() {
    set_prompt full
    zle reset-prompt
}
zle -N update-prompt
