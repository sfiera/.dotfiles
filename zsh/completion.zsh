#!/bin/zsh

autoload -U compinit
compinit

REMOTE_COMMANDS='(ssh|sshfs|sftp|scp|rsync)'
REMOTE_USERS=(sfiera chpickel)
USERS_HOSTS=(
    sfiera@{florence,a}.sfiera.net
    sfiera@{durendal,bighouse,bernhard,boomer,blake,bob}
    sfiera@{courtain,hauteclaire,sauvagine}
    chpickel@force.stwing.org
)
zstyle ":completion:*:*:$REMOTE_COMMANDS:*:users" users $REMOTE_USERS
zstyle ":completion:*:my-accounts" users-hosts $USERS_HOSTS
