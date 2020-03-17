#!/bin/bash

## Author : Aditya Shakya (adi1090x)
## Mail : adi1090x@gmail.com
## Github : @adi1090x
## Reddit : @adi1090x

rofi_command="rofi -theme themes/quicklinks.rasi"

browser="chromium"

# Links
google=""
vk=""
keybase=""
github=""
reddit=""
youtube=""
mail=""

# Variable passed to rofi
options="$vk\n$youtube\n$github\n$mail\n$reddit\n$keybase\n$google"

chosen="$(echo -e "$options" | $rofi_command -p "Open In : $browser" -dmenu -selected-row 0)"
case $chosen in
    $vk)
        $browser --new-tab https://vk.com/ctlos
        ;;
    $youtube)
        $browser --new-tab https://youtube.com
        ;;
    $github)
        $browser --new-tab https://github.com
        ;;
    $mail)
        $browser --new-tab https://mail.google.com
        ;;
    $reddit)
        $browser --new-tab https://reddit.com/r/unixporn
        ;;
    $keybase)
        $browser --new-tab https://keybase.io/cvc
        ;;
    $google)
        $browser --new-tab https://google.com
        ;;
esac
