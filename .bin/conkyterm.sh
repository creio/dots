#!/bin/bash

# This is free and unencumbered software released into the public domain.

# Anyone is free to copy, modify, publish, use, compile, sell, or
# distribute this software, either in source code form or as a compiled
# binary, for any purpose, commercial or non-commercial, and by any
# means.

# In jurisdictions that recognize copyright laws, the author or authors
# of this software dedicate any and all copyright interest in the
# software to the public domain. We make this dedication for the benefit
# of the public at large and to the detriment of our heirs and
# successors. We intend this dedication to be an overt act of
# relinquishment in perpetuity of all present and future rights to this
# software under copyright law.

# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
# IN NO EVENT SHALL THE AUTHORS BE LIABLE FOR ANY CLAIM, DAMAGES OR
# OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE,
# ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR
# OTHER DEALINGS IN THE SOFTWARE.

# For more information, please refer to <http://unlicense.org/>

VERSION='0.1'

print_help() {
	printf 'Usage: %s [-a <anchor] [-d <size>] [-h] [-o <opts>] [-p <pos>] [-s <name>] [-v] [-V] <program>\n' "$script_name"
	printf 'Executes a program in an urxvt terminal embedded in a transparent Conky window as background.\n'
	printf '\nArguments:\n'
	printf ' -a <anchor>   Sets where to calculate position from. Valid values are\n'
	printf '               top-left, top-center, top-right\n'
	printf '               center-left, center-center, center-right\n'
	printf '               bottom-left, bottom-center, bottom-right\n'
	printf '               Can be shortened as: tl, tc, tr, cl, cc, cr, bl, bc, br\n'
	printf '               Position will be calculated from anchor point of screen to anchor\n'
	printf '               point of window. Default is center-center.\n'
	printf ' -b <color>    Background color of terminal with true transparency.\n'
	printf '               Default is rgba:0000/0000/0000/0000 (Transparent)\n'
	printf ' -d <size>     Dimensions of window in pixels, in WIDTHxHEIGHT format.\n'
	printf '               Percentages can be used as well.\n'
	printf '               Default is 100%%x100%%.\n'
	printf ' -h            Prints this help page.\n'
	printf ' -o <opts>     Extra URxvt options to pass.\n'
	printf ' -p <pos>      Position of terminal on pixels, in X,Y format. Negative values are allowed.\n'
	printf '               Default is 0,0.\n'
	printf ' -s <screen>   Screen identifier, as listed in xrandr. Falls back to primary screen.\n'
	printf ' -v            Verbose, for debugging.\n'
	printf ' -V            Print version information.\n'
	printf '\nExample:\n'
	printf '  # Executes cava (Console-based Audio Visualizer for ALSA)\n'
	printf '  # as an animated background overlay in the specified screen.\n'
  printf '$ %s -s DP-1 cava\n' "$script_name"
  printf '  # Executes top in a 800x600 window with a black background.\n'
  printf '  # keeping an 50px margin from the bottom and right edges.\n'
  printf '$ %s -d 800x600 -p -50,-50 -abr -b black top\n' "$script_name"
  printf '  # Use extra URxvt argument with spaces, like a customized font:\n'
  printf '$ %s -o '\''-fn "xft:JetBrains Mono Nerd Font Mono:pixelsize=8"'\'' neofetch\n' "$script_name"
}

main() {
	local command window_id verbose urxvt_pid urxvt_command tempdir \
	      xinerama_head=0 x_pos y_pos width height config \
	      urxvt_opts=''
	      background='rgba:0000/0000/0000/0000'
	parse_arguments "$@"

	config="$(conky_config "$x_pos" "$y_pos" "$width" "$height")"
	debug "Conky Config: $config"
	tempdir=$(mktemp -d --suffix '_ct')

	conky --config=<(printf '%s' "$config") --xinerama-head="$xinerama_head" > "$tempdir/conky.log" 2>&1 &
	conky_pid=$!
	while [ -z "$window_id" ]; do
		sleep 0.1
		debug 'Waiting for Conky window'
		window_id="$(sed -n '/^conky: drawing to created window ([0-9a-fx]\+)$/{s/^.*(\([0-9a-fx]\+\))$/\1/p;q}' < "$tempdir/conky.log")"
	done
	debug "Conky window id is" "$window_id"

	urxvt_command=(urxvt +transparent -b 0 -w 1 -bl -hold -bg "$background" -embed "$window_id")
	if [ -n "$urxvt_opts" ]; then
		local opts;
		declare -a "opts=($urxvt_opts)";
		urxvt_command=("${urxvt_command[@]}" "${opts[@]}")
	fi

	urxvt_command+=(-e "$SHELL" -c "$command;printf \"\\\\e[?25l\"")
	debug "Executing ${urxvt_command[*]}"
	if [ -n "$verbose" ] ; then
		"${urxvt_command[@]}" &
	else
		"${urxvt_command[@]}" >/dev/null 2>&1 &
	fi
	urxvt_pid="$!"

	debug 'Process PID is' "$$"
	debug "Conky PID is $conky_pid"
	debug "URxvt PID is $urxvt_pid"
	wait
	cleanup
}

parse_arguments() {
	local screen script_name dim='\([0-9]\+%\?\)' pos='\(-\?[0-9]\+\)' anchor='cc'
	script_name="$(basename "$0")"
	while getopts a:b:d:ho:p:s:vV arg; do
		case $arg in
			a) anchor="$OPTARG";;
			b) background="$OPTARG";;
			d) read -r width height < <(sed -n "s/^${dim}x${dim}$/\1 \2/p" <<< "$OPTARG");;
			h) print_help; exit 0;;
			o) urxvt_opts="$OPTARG";;
			p) read -r x_pos y_pos < <(sed -n "s/^${pos},${pos}$/\1 \2/p" <<< "$OPTARG");;
			s) screen="$OPTARG";;
			v) verbose=true;;
			V) printf 'Version: %s\n' "$VERSION"; exit 0;;
			*) print_help; exit 1;;
		esac
	done
	shift $((OPTIND - 1))
	command="$*"
	if [ -z "$command" ]; then
		printf 'Command argument is missing. See %s -h.\n' "$script_name" >&2
		exit 1
	fi
	if [[ "$anchor" =~ ^(top|center|bottom)-(left|center|right)$ ]]; then
		anchor=$(sed -n 's/^\([tcb]\)[^-]\+-\([lcr]\).*$/\1\2/p' <<< "$anchor")
	fi

	if [[ ! "$anchor" =~ ^([tcb])([lcr])$ ]]; then
		printf 'Anchor "%s" is invalid. See %s -h.\n' "$anchor" "$script_name" >&2
		exit 1
	fi

	ensure_screen
	parse_dimensions
}

ensure_screen() {
	if [ -n "$screen" ] && [ "$(xrandr --listactivemonitors | sed -n '2,$s/^.*\s\(\S\+\)$/\1/p' | grep -xc "$screen")" -eq 0 ]; then
		unset screen
	fi

	if [ -z "$screen" ]; then
		screen=$(xrandr | sed -n 's/^\(\S\+\).*primary.*$/\1/p')
	fi

	xinerama_head=$(xrandr --listactivemonitors | sed -n "s/^.*\([0-9]\+\):.*\s${screen}$/\1/p")
	if [ -z "$xinerama_head" ]; then
		xinerama_head=0
	fi

	debug 'Detected xinerama_head is' "$xinerama_head"
}

parse_dimensions() {
	width=${width:-100%}
	height=${height:-100%}
	x_pos=${x_pos:-0}
	y_pos=${y_pos:-0}

	read -r screen_width screen_height < <(xrandr | sed -n "s/^${screen} .*connected[^0-9]* \([0-9]\+\)x\([0-9]\+\).*$/\1 \2/p")

	if [[ "$width" =~ %$ ]]; then
		width=$((screen_width * ${width//%/} / 100))
	fi
	if [[ "$height" =~ %$ ]]; then
		height=$((screen_height * ${height//%/} / 100))
	fi

	case "$anchor" in
		c?) y_pos=$((y_pos + (screen_height - height) / 2));;
		b?) y_pos=$((y_pos + screen_height - height));;
	esac

	case "$anchor" in
		?c) x_pos=$((x_pos + (screen_width - width) / 2));;
		?r) x_pos=$((x_pos + screen_width - width));;
	esac

	debug 'Calculated window dimensions are [' "x: $x_pos" "y: $y_pos" "w: $width" "h: $height" ']'
}

conky_config() {
	printf "
	conky.config = {
		own_window = true,
		own_window_type = 'override',
		own_window_transparent = true,
		own_window_argb_visual = true,
		update_interval = 3600,
		pad_percents = 0,

		minimum_width = %d,
		maximum_width = %d,
		minimum_height = %d,
		gap_x = %d,
		gap_y = %d,
		border_width = 0,
		border_inner_margin = 0,
		border_outer_margin = 0,
		alignment = 'top_left'
	}

	conky.text = [[]]
	" "$3" "$3" "$4" "$1" "$2"
}

debug() {
	if [ -n "$verbose" ]; then
		printf '%s\n' "$*"
	fi
}

cleanup() {
	if [ -d "$tempdir" ]; then
		debug "Cleaning up $tempdir"
		rm -rf "$tempdir"
	fi
}

_term() {
	debug "Terminating Conky ($conky_pid)"
	kill -TERM "$conky_pid"
	debug "Terminating URxvt ($urxvt_pid)"
	kill -TERM "$urxvt_pid"
	cleanup
}

trap _term SIGTERM
trap cleanup SIGINT

main "$@"
