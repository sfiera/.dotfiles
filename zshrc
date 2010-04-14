# Fix OS X's lazy profile reading
[ -z "$PROFILES" ] && . ~/.profile

# Key bindings

# ensure that 'main' is linked to 'viins'.  Should happen automatically by virtue of EDITOR=vim,
# but it never hurts to be sure.
bindkey -v

# Bindings in edit mode.
bindkey -M main '^[[3~' delete-char
bindkey -M main '^[[A' up-line-or-history
bindkey -M main '^[[B' down-line-or-history
bindkey -M main '^[[C' forward-char
bindkey -M main '^[[D' backward-char

# Bindings in command mode.
bindkey -M vicmd 'u' undo

# Set up prompts
autoload colors zsh/terminfo
if [[ "$terminfo[colors]" -ge 8 ]]; then
    colors
fi

MACHINE=%m

function tint {
    local COLOR="%{$terminfo[bold]$fg[$1]%}"
    local RESET="%{$terminfo[sgr0]%}"
    shift 1
    echo "$COLOR$*$RESET"
}

function ps_color {
    case $USER in
        root)            local PS_TEXT="$MACHINE#" ;;
        sfiera|chpickel) local PS_TEXT="$MACHINE%%" ;;
        *)               local PS_TEXT="$USER@$MACHINE%%" ;;
    esac

    PS1="[$(tint $1 $PS_TEXT)] "
    RPS1="[%~]"
}
ps_color yellow

# Alias commands
alias ls="/bin/ls -F"
alias vi="vim"
alias suvi="sudo vim"
alias si="sort | uniq"

# Load zsh completion
autoload -U compinit
compinit -C

for p in $( echo $PROFILES local ); do
    file=~/.zshrc.$p
    [ -f "$file" ] && . "$file"
done
