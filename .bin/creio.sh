#!/usr/bin/env bash
# Install script for Arch Linux
# https://raw.githubusercontent.com/creio/dots/master/.bin/creio.sh

# wget git.io/creio.sh && wget git.io/creio2.sh
# nano creio.sh
# nano creio2.sh
# sh creio.sh

Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   echo "Try 'sudo sh'"
   echo ""
   exit 1
fi

R_DISK="sda6"
B_DISK="sda2"
# H_DISK="sdb3"
S_DISK="sda3"

loadkeys ru
setfont cyr-sun16

timedatectl set-ntp true


### ////// btrfs mbr ///////
mkfs.btrfs -f -L "root" /dev/$R_DISK
mkfs.ext2 /dev/$B_DISK -L boot
mkswap -L "swap" /dev/$S_DISK

mount /dev/$R_DISK /mnt
btrfs subvolume create /mnt/@
btrfs subvolume create /mnt/@home
umount /mnt

mount -o subvol=@,compress=lzo,relatime,space_cache,autodefrag /dev/$R_DISK /mnt
mkdir /mnt/{boot,home}
mount /dev/$B_DISK /mnt/boot
mount -o subvol=@home,compress=lzo,relatime,space_cache,autodefrag /dev/$R_DISK /mnt/home
# // ssd trim
# mount -o subvol=@,compress=lzo,ssd,discard,relatime,space_cache,autodefrag /dev/$R_DISK /mnt
# mount -o subvol=@home,compress=lzo,ssd,discard,relatime,space_cache,autodefrag /dev/$R_DISK /mnt/home
swapon /dev/$S_DISK
### ////// end btrfs mbr ///////


### ////// ext4 mbr & efi ///////
# mkfs.ext4 /dev/$R_DISK -L root

# mkfs.ext2 /dev/$B_DISK -L boot
# mkfs.fat -F32 /dev/$B_DISK -L boot

# mkfs.ext4 /dev/$H_DISK -L home
# mkswap /dev/$S_DISK -L swap

# mount /dev/$R_DISK /mnt

# mkdir /mnt/{boot,home}
# mkdir -p /mnt/{boot/efi,home}

# mount /dev/$B_DISK /mnt/boot
# mount /dev/$B_DISK /mnt/boot/efi

# mount /dev/$H_DISK /mnt/home
# swapon /dev/$S_DISK
### ////// end ext4 mbr & efi ///////



pacman -Sy --noconfirm --needed reflector
reflector -c "Russia" -c "Belarus" -c "Ukraine" -c "Poland" -f 20 -l 20 -p https -p http -n 20 --save /etc/pacman.d/mirrorlist --sort rate

pacstrap /mnt base base-devel linux linux-headers nano

cp creio2.sh /mnt/creio2.sh
chmod u+x /mnt/creio2.sh

genfstab -pU /mnt >> /mnt/etc/fstab

# arch-chroot /mnt sh -c "$(curl -fsSL git.io/creio2.sh)"
arch-chroot /mnt ./creio2.sh
