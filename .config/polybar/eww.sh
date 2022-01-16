#!/usr/bin/sh

if [[ $(command -v eww) ]]; then
  if [[ ! $(pidof eww) ]]; then
    eww daemon &
  fi

  if [[ $(eww state 2>&1 | grep "ram-used" | wc -l) == 0 ]]; then
    polybar-msg hook eww_main 1
    eww open main >/dev/null 2>&1
  else
    eww close main >/dev/null 2>&1
  fi
fi
