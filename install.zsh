#!/bin/zsh

for config_file ($ZSH/**/*.symlink); do
    destination="$HOME/.${${config_file##*/}%.*}"
    ln -s "$config_file" "$destination"
done
