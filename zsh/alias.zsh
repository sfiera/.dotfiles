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
    local action
    zparseopts -D \
        a+=action \
        c+=action \
        n+=action \
        m+=action \
        d+=action \
        D+=action

    case $#action in
        0)
            if [[ $# == 0 ]]; then
                git branch
                return 0
            fi
            action=(-a)
            ;&
        1)
            case "${action[1]}$#" in
            -a1)
                if ! git show-ref --quiet --verify "refs/heads/$1"; then
                    echo "error: branch '$1' not found." >&2
                    return 1
                fi
                git checkout "$1"
                return 0 ;;
            -n1|-n2)
                git branch -- "$@"
                return 0 ;;
            -c1|-c2)
                git checkout -b "$@"
                return 0 ;;
            -m1)
                git branch -m -- "$1"
                return 0 ;;
            -m2)
                git branch -m -- "$2" "$1"
                return 0 ;;
            -d0|-D0)
                ;;
            -d*|-D*)
                git branch ${action[1]} -- "$@"
                return 0 ;;
            esac ;;
    esac

    echo "usage: $0" >&2
    echo "       $0 [-a] BRANCH" >&2
    echo "       $0 -c NEW [OLD]" >&2
    echo "       $0 -n NEW [OLD]" >&2
    echo "       $0 -m NEW [OLD]" >&2
    echo "       $0 -d BRANCH..." >&2
    echo "       $0 -D BRANCH..." >&2
    return 64
}

# if $DARWIN
alias preview="open -f -a Preview"
