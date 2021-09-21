#!/bin/bash

pkg_list=$(grep -h -v ^# ~/.pkglist.txt)
sudo pacman -S --noconfirm --needed - < $pkg_list

aur_list=$(grep -h -v ^# ~/.aurlist.txt)
yay -S --noconfirm --needed - < $aur_list
