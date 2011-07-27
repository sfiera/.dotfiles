#!/bin/zsh

alias ls="/bin/ls -F"
alias si="sort | uniq"

alias d="dirs -v"

c() {
    cd "$@" && d
}

p() {
    pushd "$@" >/dev/null && d
}

o() {
    popd "$@" >/dev/null && d
}

r() {
    case "$#" in
        0) p "+1" ;;
        1) p "+$1" ;;
        *) echo "usage: $0 N" >&2 ;;
    esac
}

# if $DARWIN
alias preview="open -f -a Preview"
