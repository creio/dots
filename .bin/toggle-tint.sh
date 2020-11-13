#!/bin/bash


# vars
# pid="$(pidof tint2)"
pid="$(ps aux | grep button.tint2rc | grep -v grep | awk -n '{print $2}')"

[[ -z ${pid} ]] && tint2 -c $HOME/.config/tint2/button.tint2rc || kill -9 "$pid"
