#!/bin/sh

IMG=$HOME/.wall/lock.png

if [[ $(command -v	multilockscreen) ]]; then
	if [[ ! -d $HOME/.cache/multilock ]]; then
		multilockscreen -u $IMG --blur 0.5
	fi

	multilockscreen $1 $2
fi
