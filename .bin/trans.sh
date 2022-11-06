#!/usr/bin/env bash
# deps: xclip translate-shell
# aur deps: rhvoice-git

icon_path="~/.icons/linebit/keyboard.png"

help_text () {
    printf "Usage: trans.sh [options] query\n"
    printf "\n"
    printf "Options:\n"
    printf "    -h    Show this help message and exit.\n"
    printf "    -i    Input results.\n"
    printf "    -c    Clip - Clipboard output results.\n"
    printf "    -b    Big output results, yad.\n"
    printf "    -p    Clip - Play output results.\n"
}

if [[ "$1" == "-i" ]]; then
    shift 1
    res=$(echo $@ | trans -brief | fold -sw40)
    notify-send -i $icon_path -t 7000 "Перевод" "$res"
elif [[ "$1" == "-c" ]]; then
    res=$(xclip -o | trans -brief | fold -sw40)
    notify-send -i $icon_path -t 7000 "Перевод" "$res"
    echo $res | xclip -selection clipboard
elif [[ "$1" == "-b" ]]; then
    res=$(xclip -o | trans -brief)
    echo "$res" | yad --text-info --width=600 --height=700 \
        --margins=15 --borders=15 --center --wrap \
        --window-icon="applications-utilities" \
        --buttons-layout=center --button="Close":1 --title="Перевод"
elif [[ "$1" == "-p" ]]; then
    if [[ $(command -v RHVoice-test) ]]; then
        ## RHVoice
        xclip -o | trans -brief | RHVoice-test -p vitaliy-ng -r 150
    else
        ## default translate shell
        xclip -o | trans -brief -p &> /dev/null
    fi
else
    help_text
fi
