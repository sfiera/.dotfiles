#!/bin/zsh

autoload -U compinit
compinit

REMOTE_COMMANDS='(ssh|sshfs|sftp|scp|rsync)'
REMOTE_USERS=(sfiera chpickel)
REMOTE_HOSTS=($(grep ^Host ~/.ssh/config | cut -d' ' -f2))
zstyle ":completion:*" users $REMOTE_USERS
zstyle ":completion:*" hosts $REMOTE_HOSTS
