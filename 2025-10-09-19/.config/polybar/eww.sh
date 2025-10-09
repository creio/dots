#!/usr/bin/sh

if [[ $(command -v eww) ]]; then
  if [[ ! $(pidof eww) ]]; then
    eww -c $HOME/.config/eww/bar daemon &
  fi

  if [[ ! $(eww -c $HOME/.config/eww/bar state 2>&1) ]]; then
    eww -c $HOME/.config/eww/bar open music_win >/dev/null 2>&1
  else
    eww -c $HOME/.config/eww/bar close music_win >/dev/null 2>&1
  fi
fi
