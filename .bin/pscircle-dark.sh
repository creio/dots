#!/usr/bin/env bash

# ffmpeg -i .wall/Crowl.png -s 1366x768 .pscircle.png
# convert -resize 1366x768 .wall/Crowl.png .pscircle.png

# xfce wall
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ~/.pscircle.png

TIME_INTERVAL=3 # Seconds

# gsettings set org.gnome.desktop.background picture-uri file:///tmp/output.png
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitor0/workspace0/last-image -s ~/.pscircle.png
# xfconf-query -c xfce4-desktop -p /backdrop/screen0/monitorVGA-0/workspace0/last-image -s ~/.pscircle.png
# hsetroot -fill $HOME/.pscircle.png

output=$HOME/.wall/pscircle.png

while [ 1 ]; do
    # Replace the next line with any parameters given in the examples.
    pscircle \
      --output-width=1366 \
      --output-height=768 \
      --background-image=$HOME/.wall/.pscircle.png \
      --link-color-min=444444 \
      --link-color-max=375143 \
      --dot-color-min=b4b6e4 \
      --dot-color-max=ffa2b1 \
      --tree-font-color=87d2ff \
      --toplists-font-color=C8D2D7 \
      --toplists-pid-font-color=7B9098 \
      --toplists-bar-background=444444 \
      --toplists-bar-color=87d2ff \
      --max-children=55 \
      --tree-radius-increment=110 \
      --dot-radius=3 \
      --link-width=1.3 \
      --tree-font-face="Clear Sans Medium" \
      --tree-font-size=11 \
      --toplists-font-size=12 \
      --toplists-bar-width=30 \
      --toplists-row-height=15 \
      --toplists-bar-height=3 \
      --cpulist-center=400.0:-80.0 \
      --memlist-center=400.0:80.0 \
      --interval=0 \
      --output=$output

    hsetroot -fill $output
    sleep $TIME_INTERVAL
done
