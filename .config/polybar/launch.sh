#!/usr/bin/env bash

killall -q polybar
while pgrep -u $UID -x polybar >/dev/null; do sleep 1; done
polybar -c $HOME/.config/polybar/config --reload top &

if [[ $(eww state 2>&1 | grep "ram-used" | wc -l) == 0 ]]; then
  sleep 2;
  polybar-msg hook eww_main 1 &
  eww open main >/dev/null 2>&1 &
fi
