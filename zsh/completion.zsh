#!/bin/zsh

autoload -U compinit
compinit -i

remote_users=("$LOGNAME")
remote_hosts=()
remote_users_hosts=()
declare -U remote_users
declare -U remote_hosts
declare -U remote_users_hosts

cat ~/.ssh/config | while read CMD VALUE UNUSED; do
    if [[ "$CMD" == "Host" ]]; then
        if [[ ! -z "$REMOTE_HOST" ]]; then
            remote_users_hosts=("$LOGNAME@$REMOTE_HOST" $remote_users_hosts)
            REMOTE_HOST=
        fi
        if [[ -z "${VALUE##*\**}" ]]; then
            REMOTE_HOST=
        else
            REMOTE_HOST="$VALUE"
            remote_hosts=("$REMOTE_HOST" $remote_hosts)
        fi
    elif [[ "$CMD" == "User" ]]; then
        REMOTE_USER="$VALUE"
        remote_users=("$REMOTE_USER" $remote_users)
        if [[ ! -z "$REMOTE_HOST" ]]; then
            remote_users_hosts=("$REMOTE_USER@$REMOTE_HOST" $remote_users_hosts)
            REMOTE_HOST=
        fi
    fi
done

zstyle ":completion:*" users $remote_users
zstyle ":completion:*" hosts $remote_hosts
zstyle ":completion:*" users-hosts $remote_users_hosts
