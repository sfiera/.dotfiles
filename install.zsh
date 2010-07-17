#!/bin/zsh

for config_file (~/.dotfiles/**/*.symlink); do
    destination="$HOME/.${${config_file##*/}%.*}"
    ln -s "$config_file" "$destination"
done
