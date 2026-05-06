#!/bin/sh

date -d "$(grep upgraded /var/log/pacman.log | tail -1 | sed -E 's/\[([^]]+)\].*/\1/')" "+%a, %d %b %Y at %H:%M"