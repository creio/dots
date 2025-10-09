#!/bin/sh

if ! updates_arch=$(checkupdates 2> /dev/null | wc -l ); then
    updates_arch=0
fi

if ! updates_aur=$(yay -Qum 2> /dev/null | wc -l); then
# if ! updates_aur=$(cower -u 2> /dev/null | wc -l); then
# if ! updates_aur=$(trizen -Su --aur --quiet | wc -l); then
# if ! updates_aur=$(pikaur -Qua 2> /dev/null | wc -l); then
    updates_aur=0
fi

updates=$(("$updates_arch" + "$updates_aur"))

if [ "$updates" -gt 0 ]; then
    echo "$updates"
else
    echo "NoUp:)"
    echo
fi

dialog_up() {
  if read -re -p "System upgrade? [y/N]: " ans && [[ $ans == 'y' || $ans == 'Y' ]]; then
    yay -Syyuu
  fi
}

if [[ $1 == "d_up" ]]; then
    dialog_up
fi
