#!/usr/bin/env bash
# vars
colors="$HOME/.bin/color"
w="$(xdotool getdisplaygeometry | awk '{print $2}')"
h="$(xdotool getdisplaygeometry | awk '{print $1}')"
refresh="10"
padding="    "
height="35"
offx="$(($h - 125))"
offy="$(($w - 75))"
font="-*-euphon-*"
font2="-*-ijis-*"
font3="-*-vanilla-*"
font4="-efont-biwidth-*"


# colors
source "$colors"


# functions
clock() {
	date "+%R"
}


# loops
loop() {
	while :; do
		echo "%{c}%{A:calendar &:}$(clock)%{A}$f"
		sleep "$refresh"
	done |\

	lemonbar \
		-f "$font" \
		-f "$font2" \
		-f "$font3" \
		-f "$font4" \
		-g "75x$height+$offx+$offy" \
		-F "$text" \
		-B "$color0" \
		-d \
	| bash &

	n30f -x "$(($offx - 5))" \
		 -y "$(($offy - 5))" \
		 "$HOME/.bin/img/small.png"
}


# exec
loop
