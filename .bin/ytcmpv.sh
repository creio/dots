#!/usr/bin/env bash
# https://github.com/philc/vimium/issues/2916#issuecomment-521987897

notify-send -t 5000 -i mpv \
"Playing $(xclip -o -sel clip | xargs youtube-dl -e)"

mpv $(xclip -o -sel clip)
