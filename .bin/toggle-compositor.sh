#!/bin/bash

# vars
pid="$(pidof picom)"

# exec
if test "$pid"; then
	kill -9 "$pid"
	notify-send "compositor disabled"
else
	picom &
	disown
	notify-send "compositor enabled"
fi
