#!/usr/bin/env bash
# Install script yay
# autor: Alex Creio https://cvc.hashbase.io/

git clone https://aur.archlinux.org/yay.git
cd yay
makepkg -si
cd ..
rm -rf yay