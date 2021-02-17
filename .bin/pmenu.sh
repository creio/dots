#!/bin/sh

terminal=urxvt
iconpath=$HOME/.icons/linebit
# IMG:$iconpath/appearance.png

cat <<EOF | pmenu -w | sh &
IMG:$iconpath/start.png	rofi -show drun -theme ~/.config/rofi/drun.rasi
IMG:$iconpath/search.png	search
IMG:$iconpath/chromium.png	chromium
IMG:$iconpath/terminal.png	draw
IMG:$iconpath/files.png	$terminal -name term_center -e ranger
IMG:$iconpath/submenu.png
	IMG:$iconpath/lock.png	multilock.sh -l dimblur
	IMG:$iconpath/logout.png	exit openbox
	IMG:$iconpath/reboot.png	reboot
	IMG:$iconpath/poweroff.png	poweroff
EOF
