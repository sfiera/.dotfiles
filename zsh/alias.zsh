#!/bin/zsh

alias ls="/bin/ls -F"
alias si="sort | uniq"

alias d="dirs -v"

cd() {
    builtin cd "$@" && d
}

pd() {
    pushd "$@" && d
}

od() {
    popd "$@" && d
}

rd() {
    case "$#" in
        0) pd "+1" ;;
        1) pd "+$1" ;;
        *) echo "usage: $0 N" >&2 ;;
    esac
}

b() {
    git branch
}

cb() {
    case "$#" in
        0|1) git checkout "${1-master}" ;;
        2) case $1 in
            -x) git checkout -b "$2" ;;
            *)  echo "usage: $0 [-x] [BRANCH]" >&2 ;;
        esac ;;
        *) echo "usage: $0 [-x] [BRANCH]" >&2 ;;
    esac
}

# if $DARWIN
alias preview="open -f -a Preview"
