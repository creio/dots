#!/usr/bin/env bash
# Install script yay
# autor: Alex Creio https://creio.github.io/

# curl -L git.io/yay.sh | sh

sudo pacman -S --noconfirm --needed curl git
git clone https://aur.archlinux.org/yay-bin.git
cd yay-bin
# makepkg -si
makepkg -si --skipinteg --noconfirm
cd ..
rm -rf yay-bin
