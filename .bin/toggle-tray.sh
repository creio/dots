#!/bin/bash


# vars
# pid="$(pidof stalonetray)"
pid="$(ps aux | grep tray.tint2rc | grep -v grep | awk -n '{print $2}')"


# exec
if test "$pid"; then
	# killall "stalonetray"
	kill -9 $pid 2> /dev/null
	# kill -TERM $pid || kill -KILL $pid
else
	# stalonetray &
	tint2 -c $HOME/.config/tint2/tray.tint2rc &
fi