#!/bin/bash

# vars
pid="$(pidof zentile)"

# exec
if test "$pid"; then
  kill -9 "$pid"
  notify-send "zentile disabled"
else
  zentile &
  # disown
  notify-send "zentile enabled"
fi
