#!/usr/bin/env bash
# MIT License. Copyright (c) 2020 Just Perfection
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included in all
# copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
# SOFTWARE.

# depends: xdotool

function printf_color {
		printf "\033[0;$2m$1\033[0m";
}

function generate_tray {
		local -n arr=$1;
		declare -a local items;

		for name in "${!arr[@]}"; do
				cmd_output="${arr[$name]}";
				if [[ $cmd_output ]]
				then
						items+=($name);
				fi
		done

		items_str=${items[@]};
		printf "${items_str// /	 }";
}

function finalize {
		local ws="$1";
		local datetime="$2";
		local tray="$3";

		printf "\n ";
		printf_color " $ws " 41;
		printf_color "	$tray " 37;
		printf "\n\n ";
		printf_color "$datetime" 34;
		printf "\n\n";
}

date=$(date "+%d %b %a %I:%M %p");

xdotool_num=$(xdotool get_desktop);
ws_num=$((xdotool_num + 1));

declare -A tray;
tray['GMB']=$(pidof -x gmusicbrowser.pl);
tray['Discord']=$(pidof Discord);
tray['Telegram']=$(pidof telegram-desktop);
tray['Caffeine']=$(pidof -x caffeine-ng);
tray['Private']=$(ip link | grep wgoc);

tray_str=$(generate_tray tray);

finalize $ws_num "$date" "$tray_str";

# notify-send "${ws_num} ${tray_str}
# ${date}"
