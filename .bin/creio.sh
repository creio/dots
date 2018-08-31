#!/usr/bin/env bash
# Install script for Arch Linux

# https://raw.githubusercontent.com/creio/dots/master/.bin/creio.sh

# wget git.io/creio.sh
# nano creio.sh
# sh creio.sh

Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   echo "Try 'sudo sh'"
   echo ""
   exit 1
fi


R_DISK="sdb1"
B_DISK="sdb2"
H_DISK="sdb3"
S_DISK="sdb4"

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true

mkfs.ext4 /dev/$R_DISK -L root
mkfs.ext2 /dev/$B_DISK -L boot
mkfs.ext4 /dev/$H_DISK -L home
mkswap /dev/$S_DISK -L swap

mount /dev/$R_DISK /mnt
mkdir /mnt/{boot,home}
mount /dev/$B_DISK /mnt/boot
mount /dev/$H_DISK /mnt/home
swapon /dev/$S_DISK

pacman -Sy --noconfirm --needed reflector
sudo reflector -c "Belarus" -c "Russia" -c "Ukraine" -c "Poland" -f 20 -l 20 -p https -p http -n 20 --save /etc/pacman.d/mirrorlist --sort rate

pacstrap /mnt base

cp creio2.sh /mnt/creio2.sh
chmod u+x /mnt/creio2.sh

genfstab -pU /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/creio2.sh)"
arch-chroot /mnt ./creio2.sh