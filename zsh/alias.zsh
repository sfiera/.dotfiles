#!/bin/zsh

alias ls="/bin/ls -F"
alias si="sort | uniq"
alias cloak="cloak -f'./%g/%b/%A/%d%k%t'"
alias pbedit="pbpaste | vipe | pbcopy"

alias d="dirs -v"

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

b() {
    local action
    local all
    local verbose
    if ! zparseopts -D \
            a+:=action \
            c+:=action \
            n+:=action \
            m+:=action \
            d+=action \
            D+=action \
            A+=all \
            v+=verbose; then
        return false
    fi

    if [[ $#all > 0 ]]; then
        all=(-a)  # lowercase
    fi

    case $#action in
        0)
            if [[ $# == 0 ]]; then
                git branch $verbose $all
                return 0
            fi
            action=(-a $1); shift
            ;&
        2)
            case "${action[1]}$#" in
            -a0)
                BRANCH="${action[2]}"
                if ! git show-ref --quiet --verify "refs/heads/$BRANCH"; then
                    echo "error: branch '$BRANCH' not found." >&2
                    return 1
                fi
                # Stash changes unconditionally--will fail if nothing to stash; that's OK.
                git stash save "b: stashing before switching branches." >/dev/null
                git checkout "$BRANCH"
                git stash list | sed 's/^\(stash@{[0-9]*}\): On \(.*\): .*: stashing before switching branches\.$/\1 \2/' | while read NAME BRANCH2; do
                    if [[ "$BRANCH" == "$BRANCH2" ]]; then
                        git stash pop "$NAME" >/dev/null
                    fi
                done
                return 0 ;;
            -n0|-n1)
                git branch -- "$@" "${action[2]}"
                return 0 ;;
            -c0|-c1)
                git checkout -b "${action[2]}" "$@"
                return 0 ;;
            -m0|-m1)
                git branch -m -- "$@" "${action[2]}"
                return 0 ;;
            esac ;;
        1)
            case "${action[1]}$#" in
            -d0|-D0)
                ;;
            -d*|-D*)
                git branch ${action[1]} -- "$@"
                return 0 ;;
            esac ;;
    esac

    echo "usage: $0 [-Av]" >&2
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
