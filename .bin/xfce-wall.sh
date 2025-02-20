#!/bin/bash

# exit if the script has been run before
[[ -f ~/.cache/.xfdesktop-post.run ]] && exit 1

xfconf-query -c xfce4-desktop -l | grep last-image | while read path; do
  xfconf-query -c xfce4-desktop -p $path -s /path/to/image.png
done

# leave marker that script has been run
touch ~/.cache/.xfdesktop-post.run

exit 0
