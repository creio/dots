#!/bin/bash
# baraction.sh script for spectrwm status bar

SLEEP_SEC=5  # set bar_delay = 5 in /etc/spectrwm.conf
COUNT=0
#loops forever outputting a line every SLEEP_SEC secs
while :; do
  let COUNT=$COUNT+1
        echo -e "         Hello World! $COUNT"
        sleep $SLEEP_SEC
done
