#!/bin/bash

# if [[ ! $(command -v torrserver) || $EUID != 0 ]]; then
#		echo "yay -S torrserver-bin"
#		echo "run root" && exit
# fi

pid="$(pidof torrserver)"
[[ -z ${pid} ]] && GODEBUG=madvdontneed=1 \
torrserver -d /media/files/torrserver \
-l /media/files/torrserver/torrents \
-t /media/files/torrserver/torrents &>/dev/null &

[[ -z "$1" && -z "$2" ]] && exit

if [[ "$1" == "-s" ]]; then
	torrent_link=$2
	mpv "http://127.0.0.1:8090/stream/fname?link=$torrent_link&index=1&play&save"
elif [[ "$1" == "-k" ]]; then
  killall torrserver
else
	torrent_link=$1
	mpv "http://127.0.0.1:8090/stream/fname?link=$torrent_link&index=1&play"
fi
