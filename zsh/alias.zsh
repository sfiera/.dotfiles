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
                _b_list_branches $#verbose
                return $?
            fi
            action=(-a $1); shift
            ;&
        2)
            case "${action[1]}$#" in
            -a0)
                BRANCH="${action[2]}"
                if ! git show-ref --quiet --verify "refs/heads/$BRANCH"; then
                    echo "$@: branch not found." >&2
                    return 1
                fi
                git freeze
                git checkout "$BRANCH"
                git thaw
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

_b_list_branches() {
    local verbosity=$1
    local head=$(git symbolic-ref HEAD 2>/dev/null)
    local ref ref_short upstream upstream_short
    local head_color behind ahead
    local -A upstreams short behinds aheads

    if ! git rev-parse --show-toplevel >/dev/null 2>/dev/null; then
        git rev-parse --show-toplevel
        return $?
    fi

    if g diff --quiet HEAD; then
        head_color=2
    elif git diff --quiet; then
        head_color=142
    else
        head_color=1
    fi

    g for-each-ref --format='%(refname) %(refname:short) %(upstream) %(upstream:short)' refs/heads \
            | while read ref ref_short upstream upstream_short; do
        short[$ref]=$ref_short
        upstreams[$ref]=$upstream
        if [[ -n $upstream ]]; then
            short[$upstream]=$upstream_short
            git rev-list --left-right --count $upstream...$ref | read behind ahead
            if [[ $behind > 0 ]]; then
                behinds[$ref]="-$behind"
            fi
            if [[ $ahead > 0 ]]; then
                aheads[$ref]="+$ahead"
            fi
        fi
    done

    recurse() {
        local prefix=$1 upstream=$2 head=$3 head_color=$4

        for ref in ${(k)short}; do
            if [[ $upstreams[$ref] == $upstream ]]; then
                if [[ $ref == $head ]]; then
                    echo -n "$prefix\e[38;5;${head_color}m* \e[1m${short[$ref]}\e[0m"
                else
                    echo -n "$prefix  ${short[$ref]}"
                fi
                echo -n "\e[38;5;2m${aheads[$ref]}\e[0m"
                echo -n "\e[38;5;1m${behinds[$ref]}\e[0m"
                echo
                recurse "$prefix  " $ref $head $head_color
            fi
        done
    }

    recurse "" "" $head $head_color
}

g() {
    if [[ $# == 0 ]]; then
        git status --short --branch
    else
        git "$@"
    fi
}
