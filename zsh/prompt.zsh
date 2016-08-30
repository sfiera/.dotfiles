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
    if GITREF=$(/usr/bin/git symbolic-ref HEAD 2>/dev/null); then
        echo ${GITREF#refs/heads/}
    else
        return 1
    fi
}

function git_ref {
    GITREF=$(/usr/bin/git rev-parse HEAD)
    echo "${GITREF[0,7]}"
}

function git_ahead {
    local GIT_BRANCH=$1
    local GIT_REMOTE GIT_MERGE GIT_UPSTREAM
    if ! GIT_REMOTE=$(/usr/bin/git config branch.$GIT_BRANCH.remote 2>/dev/null); then
        return
    fi
    if ! GIT_MERGE=$(/usr/bin/git config branch.$GIT_BRANCH.merge 2>/dev/null); then
        return
    fi
    if [[ $GIT_REMOTE == "." ]]; then
        GIT_UPSTREAM=$GIT_MERGE
    else
        GIT_UPSTREAM=$GIT_REMOTE/${GIT_MERGE#refs/heads/}
    fi
    local GIT_AHEAD=0 GIT_BEHIND=0
    /usr/bin/git rev-list --left-right $GIT_ORIGIN...$GIT_UPSTREAM | while read LINE; do
        if [[ ${LINE[1]} == ">" ]]; then
            ((GIT_BEHIND+=1))
        else
            ((GIT_AHEAD+=1))
        fi
    done
    if [[ $GIT_AHEAD > 0 ]]; then
        echo -n $(tint $CLEAN_COLOR +$GIT_AHEAD)
    fi
    if [[ $GIT_BEHIND > 0 ]]; then
        echo -n $(tint $DIRTY_COLOR -$GIT_BEHIND)
    fi
    echo
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

PS1_PATH=
function set_prompt {
    local PS_COLOR="${PS_COLORS[$MACHINE]-142}"
    local NEWLINE="
"
    local HERE="%~"
    HERE="${(%)HERE}"

    case $USER in
        root|sfiera|chpickel)   local LOCATION="$MACHINE" ;;
        *)                      local LOCATION="$USER@$MACHINE" ;;
    esac
    PS1="$(tint -b $PS_COLOR $LOCATION)"

    if [[ $1 == fast ]]; then
        # Reuse PS1_PATH
    elif /usr/bin/git rev-parse --show-toplevel >/dev/null 2>/dev/null; then
        local GIT_PREFIX=$(/usr/bin/git rev-parse --show-prefix)
        GIT_PREFIX=${GIT_PREFIX%/}
        local GIT_TOPLEVEL=${HERE%${GIT_PREFIX}}
        if [[ ( $GIT_TOPLEVEL != $HERE ) || -z $GIT_PREFIX ]]; then
            PS1_PATH="$(tint $DIM_COLOR $GIT_TOPLEVEL)$GIT_PREFIX"
        else
            PS1_PATH="$HERE"
        fi
        local GIT_BRANCH
        if GIT_BRANCH=$(git_branch); then
            PS1_PATH="$PS1_PATH:$(tint $(git_color) $GIT_BRANCH)$(git_ahead $GIT_BRANCH)"
        else
            PS1_PATH="$PS1_PATH:$(tint $(git_color) \($(git_ref)\))"
        fi
    else
        PS1_PATH="$HERE"
    fi
    PS1="$PS1:$PS1_PATH"

    if [[ $KEYMAP == vicmd ]]; then
        PS1="$PS1$NEWLINE$(tint -r -b $PS_COLOR %#) "
    else
        PS1="$PS1$NEWLINE$(tint -b $PS_COLOR %#) "
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
