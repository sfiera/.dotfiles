#!/bin/zsh

alias ls="/bin/ls -F"
alias si="sort | uniq"
alias cloak="cloak --path='./%g/%@/%A/%d%k%t'"
alias suvi="sudo -e"
alias pk="pkill -fI"

alias d="dirs -v"

alias -g …="|expand-elastic|less"

function $ { echo $ $*; $* }
function @ { echo $*; $* }
function lsn { ls $* | sort -n | column }

# Preserve directory stack across exec and into subshelss
update_dirs() {
    pwds=()
    dirs -lp | while read DIR; do
        pwds=($pwds $DIR)
    done
}
typeset -T PWDS pwds
if [[ "${#pwds}" == 0 ]]; then
    update_dirs
else
    builtin dirs -c
    builtin cd $pwds[${#pwds}]
    if [[ ${#pwds} > 1 ]]; then
        for ((i = $((${#pwds} - 1)); i > 0; --i)); do
            builtin pushd -q $pwds[$i]
        done
    fi
fi
export PWDS

cd() {
    builtin cd "$@" && update_dirs && d
}

pd() {
    pushd "$@" && update_dirs && d
}

od() {
    popd "$@" && update_dirs && d
}

rd() {
    case "$#" in
        0) pd "+1" ;;
        1) pd "+$1" ;;
        *) echo "usage: $0 N" >&2 ;;
    esac
}

g() {
    if [[ $# == 0 ]]; then
        git status --short --branch
    else
        git "$@"
    fi
}
