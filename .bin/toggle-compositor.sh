#!/bin/bash


# vars
pid="$(pidof compton)"


# exec
if test "$pid"; then
	kill -9 "$pid"
	notify-send "compositor disabled"
else
	compton &
	disown
	notify-send "compositor enabled"
fi