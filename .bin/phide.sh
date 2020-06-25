#!/bin/sh

# TOGGLE_CMD='polybar-msg cmd toggle &'
# pacman -S xdo

BAR_HEIGHT_SHOW=2
BAR_HEIGHT_HIDE=22
SHOW_CMD='xdo show -N Polybar'
HIDE_CMD='xdo hide -N Polybar'

# Return y-position of cursor
get_y_position() {
    loc=$(xdotool getmouselocation --shell | grep Y)
    echo ${loc:2}
}

hidden=true
eval $HIDE_CMD
while :; do

    y_loc=$(get_y_position)
    sleep 0.10

    if (( y_loc < BAR_HEIGHT_SHOW )) && [ "$hidden" = true ]; then
        eval $SHOW_CMD
        hidden=false
    fi

    if (( y_loc >= BAR_HEIGHT_HIDE )) && [ "$hidden" = false ]; then
        eval $HIDE_CMD
        hidden=true
    fi
done
