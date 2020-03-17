#!/bin/bash

## Author : Aditya Shakya (adi1090x)
## Mail : adi1090x@gmail.com
## Github : @adi1090x
## Reddit : @adi1090x

rofi_command="rofi -theme themes/menu/screenshot.rasi"

# Options
screen=""
area=""
crop_d=""
window=""

# Variable passed to rofi
options="$screen\n$area\n$crop_d\n$window"

chosen="$(echo -e "$options" | $rofi_command -p '' -dmenu -selected-row 1)"
case $chosen in
    $screen)
        # sleep 1; scrot 'scrot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES) ; viewnior $$(xdg-user-dir PICTURES)/$f'
        flameshot full -c -p $(xdg-user-dir PICTURES)
        ;;
    $area)
        # scrot -s 'scrot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES) ; viewnior $$(xdg-user-dir PICTURES)/$f'
        flameshot gui
        ;;
    $crop_d)
        flameshot gui -d 5000
        ;;
    $window)
        sleep 1; scrot -u 'scrot_%Y-%m-%d-%S_$wx$h.png' -e 'mv $f $$(xdg-user-dir PICTURES)/screen ; viewnior $$(xdg-user-dir PICTURES)/screen/$f'
        ;;
esac
