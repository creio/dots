#!/usr/bin/sh

# if (($(ps -aux | grep [p]icom | wc -l) > 0))

if [[ $(ps -aux | grep "[p]icom_blur" | wc -l) == 1 ]]; then
  polybar-msg hook blur_picom 1
  pkill -9 picom
  sleep 0.1
  picom -b --config ~/.config/picom.conf &
  disown
  notify-send "disable picom blur"
else
  polybar-msg hook blur_picom 2
  pkill -9 picom
  sleep 0.1
  # picom -b --config=/home/gideon/.config/picom/picom.conf --experimental-backends --backend glx --blur-method dual_kawase &
  picom -b --config ~/.config/picom_blur.conf &
  disown
  notify-send "enable picom blur"
fi