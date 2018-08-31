#!/bin/sh

DIALOG_RESULT=$(echo -e 'exit i3\nsuspend\nhibernate\nreboot\npoweroff\nexit' | rofi -dmenu -i -p "[SYSTEM]" -hide-scrollbar -tokenize -lines 6 -eh 1 -width 25 -location 0 -xoffset 0 -yoffset 0 -padding 20 -disable-history -font "ClearSansMedium 14")

echo "This result is : $DIALOG_RESULT"
sleep 1;

if [ "$DIALOG_RESULT" = "exit i3" ];
then
    i3-msg 'exit'
elif [ "$DIALOG_RESULT" = "suspend" ];
then
    exec systemctl suspend
elif [ "$DIALOG_RESULT" = "hibernate" ];
then
    exec systemctl hibernate
elif [ "$DIALOG_RESULT" = "reboot" ];
then
    exec systemctl reboot
elif [ "$DIALOG_RESULT" = "poweroff" ];
then
    exec systemctl poweroff
elif [ "$DIALOG_RESULT" = "exit" ];
then
    exit 0
fi