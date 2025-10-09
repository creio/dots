#!/bin/bash

killall -q conky

conky -c ~/.conky/conky_asset -d
conky -c ~/.conky/conky_connections -d
conky -c ~/.conky/conky_biclock -d
conky -c ~/.conky/conky.conf -d
conky -c ~/.conky/conky_cpus -d
conky -c ~/.conky/conky_sensors -d
conky -c ~/.conky/conky_wtr -d
conky -c ~/.conky/conky_hdd -d
conky -c ~/.conky/conky_cal -d
conky -c ~/.conky/conky_loggs -d
conky -c ~/.conky/conky_processes -d
# conky -c ~/.conky/conky_gmail -d
# conky -c ~/.conky/conky_weather -d
