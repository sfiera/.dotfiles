#!/bin/zsh

alias ls="/bin/ls -F"
alias si="sort | uniq"

alias d="dirs -v"

cd() {
    builtin cd "$@" && d
}

pd() {
    pushd "$@" >/dev/null && d
}

od() {
    popd "$@" >/dev/null && d
}

rd() {
    case "$#" in
        0) pd "+1" ;;
        1) pd "+$1" ;;
        *) echo "usage: $0 N" >&2 ;;
    esac
}

# if $DARWIN
alias preview="open -f -a Preview"
