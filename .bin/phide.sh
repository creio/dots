#!/bin/sh

# 1 variant
# TOGGLE_CMD='polybar-msg cmd toggle &'
# SHOW_CMD='polybar-msg cmd show &'
# HIDE_CMD='polybar-msg cmd hide &'

# 2 variant
# pacman -S xdo
# SHOW_CMD='xdo show -N Polybar'
# HIDE_CMD='xdo hide -N Polybar'

BAR_HEIGHT_SHOW=2
BAR_HEIGHT_HIDE=22
SHOW_CMD='polybar-msg cmd show &'
HIDE_CMD='polybar-msg cmd hide &'

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
