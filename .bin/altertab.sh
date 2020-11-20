#!/usr/bin/sh

pid="$(pidof alttab)"

# exec
if [[ -n "$pid" ]]; then
  echo
else
  alttab -fg "#9baec8" -bg "#161720" \
    -frame "#5a74ca" -t 128x128 -i 128x48 -d 2 \
    -theme Qogir-dark -font "xft:ClearSansMedium:size=9:antialias=false" \
    -pk "Left" -nk "Right" &
fi


