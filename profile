# Load relevant profiles
export PROFILES="`[ -f ~/.profiles ] && cat ~/.profiles`"

# Set up editors
export EDITOR=vim
export VISUAL=vim

# Add common path locations
export PATH=~/bin:$PATH:/usr/games
export PYTHONPATH=~/lib/python:$PYTHONPATH
export MANPATH=~/share/man:$MANPATH

# Ensure all these are exported
export TERM=xterm-color
export PATH
export HOSTNAME=`hostname`

for p in $( echo $PROFILES local ); do
    file=~/.profile.$p
    [ -f "$file" ] && . "$file"
done
