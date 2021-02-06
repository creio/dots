#!/usr/bin bash

pack=(
oh-my-zsh-git zsh-autosuggestions
ttf-clear-sans ttf-roboto-mono capitaine-cursors
caffeine-ng sublime-text-dev timeshift
xsettingsd skippy-xd-git
tint2-git
)

yay -Sy --noconfirm --needed ${pack[@]}

echo "Aur pkg install Complete"
