[[ $(uname) == "Linux" ]] || return

alias varnishadm="sudo varnishadm -S/etc/varnish/secret -Tlocalhost:6082"
