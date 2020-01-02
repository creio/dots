#!/bin/bash

# Minimalistic random wallpaper downloader, uses unsplash as source because they seem to have the best wallpapers.
# I guess i could add an favourites option later on but for now it works for me-
# Requirements:
#              feh, wget, imlib2, curl, imagemagic
# battery=$(cat /sys/class/power_supply/BAT1/capacity)
# weather=$(cat /tmp/weather.tmp)
# date=$(date +"%H:%M")
savelocation=/tmp/wall.jpg
statslocation=/tmp/wall-stats.jpg
imgprovider=https://source.unsplash.com/1920x1080/?nature,dark

wget -N  "$imgprovider" -O "$savelocation" 2> /dev/null
# convert -pointsize 48 -fill white -annotate +1200+1000 "$weather | $date | $battery%" $savelocation $statslocation
hsetroot -fill "$savelocation"
dunstify "New wallpaper set!"
