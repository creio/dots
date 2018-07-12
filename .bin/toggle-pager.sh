#!/bin/bash


# vars
pid="$(pidof netwmpager)"


# exec
if test "$pid"; then
	kill -9 "$pid"
else
	netwmpager &
	disown
fi