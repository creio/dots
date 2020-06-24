#!/bin/bash
# autor Alex Creio

SCREEN_DIR=$(xdg-user-dir PICTURES)/screen

[[ ! -d $SCREEN_DIR ]] && mkdir -p $SCREEN_DIR

if [ "$1" = "-c" ]; then
  flameshot full -c -p $SCREEN_DIR
elif [ "$1" = "-d" ]; then
  flameshot full -c -d "$2" -p $SCREEN_DIR
else
  flameshot gui
fi
