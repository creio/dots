#!/usr/bin/bash

MAIN_PID=".*--proxy-server"
if [[ $(pgrep -f "$MAIN_PID") ]]; then
  pkill -f "$MAIN_PID"
  notify-send "Kill proxy browser"
  polybar-msg action "#vpn.hook.0"
elif [[ $(ss -tlnp 2>/dev/null | grep -i ":2080 ") ]]; then
  brave --proxy-server='socks://127.0.0.1:2080' &
  sleep 2
  notify-send "Start proxy browser"
  polybar-msg action "#vpn.hook.1"
else
  notify-send "NO PROXY :2080"
fi