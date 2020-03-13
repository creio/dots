#!/bin/bash
killall picom

if [ "$1" = "glx" ]; then
    picom --config $HOME/.config/picom.conf -b
else
    picom --config $HOME/.config/picom.conf --backend xrender -b
fi
