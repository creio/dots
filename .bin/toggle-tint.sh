#!/bin/bash


# vars
# pid="$(pidof tint2)"
pid="$(ps aux | grep button.tint2rc | grep -v grep | awk -n '{print $2}')"

# exec
if test "$pid"; then
	kill -9 "$pid"
else
	tint2 -c $HOME/.config/tint2/button.tint2rc
fi
