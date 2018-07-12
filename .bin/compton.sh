#!/bin/bash
killall compton

if [ "$1" = "glx" ]; then
    compton --config $HOME/.config/compton.conf -b
else
    compton --config $HOME/.config/compton.conf --backend xrender -b
fi
