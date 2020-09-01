#!/bin/bash

APPS=(
	'conky1'
	'conky2'
)

APP_conky1_cmd="conky -c $HOME/.conkyrc1"
APP_conky2_cmd="conky -c $HOME/.conkyrc2"



desktop=`$HOME/bin/show_desktop -q`
[ $? -eq 0 ] || exit 1

start() {
	echo "Starting: $1"
	eval "cmd=\$APP_${1}_cmd"
	$cmd &

	if [ -n $! ]; then
		# Re-position window?
		eval "x=\$APP_${1}_winx"
		eval "y=\$APP_${1}_winy"
		if [ -n "$x" -a -n "$y" ]; then
			eval "title=\$APP_${1}_wintitle"
			# the sleep gives the window time to show up
			$(sleep 1; wmctrl -r $title -e "0,$x,$y,-1,-1") &

			# alternate method which doesn't require the window title
			#xdotool getactivewindow windowmove $x $y
		fi
	fi
}

stop() {
	eval "cmd=\$APP_${1}_cmd"
	pid=`pgrep -f "$cmd"`
	if [ -n "$pid" ]; then
		echo "Killing pid: $pid ($cmd)"
		kill $pid
	fi
}

if [ "$desktop" == "visible" ]; then
	# Fire up our widget apps
	for app in "${APPS[@]}"; do
		start "$app"
	done
fi

if [ "$desktop" == "hidden" ]; then
	# Kill our widget apps
	for app in "${APPS[@]}"; do
		stop "$app"
	done
fi
