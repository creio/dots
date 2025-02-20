#!/bin/sh

IMG=$HOME/.wall/lock.png

if [[ $(command -v	betterlockscreen) ]]; then
	if [[ ! -d $HOME/.cache/betterlockscreen ]]; then
		betterlockscreen -u $IMG --blur 0.5
	fi

	betterlockscreen $1 $2
fi
