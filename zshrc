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
    shift
    echo "$COLOR$*$RESET"
}

function ps_color {
    case $USER in
        root)            local LOCATION="$MACHINE" ;;
        sfiera|chpickel) local LOCATION="$MACHINE" ;;
        *)               local LOCATION="$USER@$MACHINE" ;;
    esac

    if [[ -n $2 ]]; then
        PS1="
$(tint $1 $LOCATION):%~:$(tint yellow $2)
$(tint $1 %#) "
    else
        PS1="
$(tint $1 $LOCATION):%~
$(tint $1 %#) "
    fi
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

typeset -ga precmd_functions
typeset -ga chpwd_functions
typeset -ga preexec_functions

function set_git_prompt {
  GITREF=$(git symbolic-ref HEAD 2> /dev/null)
  if [[ -n $GITREF ]]; then
      GITBRANCH="${GITREF#refs/heads/}"
  else
      GITBRANCH=""
  fi
  ps_color cyan $GITBRANCH
}

function zsh_git_prompt_precmd {
    if [[ -n "$PR_GIT_UPDATE" ]]; then
        set_git_prompt
        PR_GIT_UPDATE=
    fi
}
precmd_functions+=zsh_git_prompt_precmd

function zsh_git_prompt_chpwd {
    PR_GIT_UPDATE=1
}
chpwd_functions+=zsh_git_prompt_chpwd

function zsh_git_prompt_preexec {
    case "$(history $HISTCMD)" in
        *git*) PR_GIT_UPDATE=1 ;;
    esac
}
preexec_functions+=zsh_git_prompt_preexec

PR_GIT_UPDATE=1

for p in $( echo $PROFILES local ); do
    file=~/.zshrc.$p
    [ -f "$file" ] && . "$file"
done
