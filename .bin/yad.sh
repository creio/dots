#! /bin/bash

action=$(yad --entry --title "System Logout" \
	--center --borders=20 --width 300 \
	--image=gnome-shutdown \
	--button="Switch User:2" \
	--button="ok:0" --button="close:1" \
	--text "Choose action:" \
	--entry-text \
	"Power Off" "Reboot" "Suspend" "Logout")
res=$?

[[ $res == 1 ]] && exit 0

if [[ $res == 2 ]]; then
	gdmflexiserver --startnew &
	exit 0
fi

case $action in
	Power*) cmd="sudo poweroff" ;;
	Reboot*) cmd="sudo reboot" ;;
	Suspend*) cmd="sudo systemctl suspend" ;;
	Logout*)
	case $(wmctrl -m | grep Name) in
		*Openbox) cmd="openbox --exit" ;;
		*FVWM) cmd="FvwmCommand Quit" ;;
		*Metacity) cmd="gnome-save-session --kill" ;;
		*) exit 1 ;;
	esac
	;;
	*) exit 1 ;;
esac

eval exec $cmd
