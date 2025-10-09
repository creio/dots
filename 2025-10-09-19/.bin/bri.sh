#!/bin/sh

pid="$(pidof redshift)"

if [[ -z $1 ]]; then
  # echo "BRIGHTNESS"
  if test "$pid"; then
    pkill -9 redshift
    notify-send "disable redshift"
    xrandr --listmonitors | grep "^ " | cut -f 6 -d' ' | \
    xargs --replace=MONITOR xrandr --output MONITOR --brightness 1 --gamma 1:1:1
  else
    xrandr --listmonitors | grep "^ " | cut -f 6 -d' ' | \
    xargs --replace=MONITOR xrandr --output MONITOR --brightness 1 --gamma 1:1:1
    redshift -c ~/.config/redshift.conf &
    notify-send "enable redshift"
  fi
else
  pkill -9 redshift
  xrandr --listmonitors | grep "^ " | cut -f 6 -d' ' | \
  xargs --replace=MONITOR xrandr --output MONITOR --brightness $1 --gamma $2
  notify-send "disable redshift, enable BRIGHTNESS"
fi
