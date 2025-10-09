#!/bin/bash


# vars
# pid="$(pidof dunst)"
pid="$(ps aux | grep dunstrc | grep -v grep | awk -n '{print $2}')"


# exec
if test "$pid"; then
	# killall "dunst"
	kill -9 "$pid"
	dunst -conf $HOME/.config/dunst/dunstnorc &
	notify-send "dunst notify No"
else
	killall "dunst"
	dunst -conf $HOME/.config/dunst/dunstrc &
	notify-send "dunst notify Yes"
fi