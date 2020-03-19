#!/usr/bin/env bash
# Install script for Arch Linux
# https://raw.githubusercontent.com/creio/dots/master/.bin/creio2.sh

# wget git.io/creio2.sh
# nano creio2.sh

DISK="sda"

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Sy --noconfirm --needed reflector
reflector -c "Russia" -c "Belarus" -c "Ukraine" -c "Poland" -f 20 -l 20 -p https -p http -n 20 --save /etc/pacman.d/mirrorlist --sort rate

echo "Arch Linux Virtualbox?"
read -p "yes, no: " virtualbox_setting
if [[ $virtualbox_setting == no ]]; then
  virtualbox_install=""
elif [[ $virtualbox_setting == yes ]]; then
  virtualbox_install="virtualbox-guest-modules-arch virtualbox-guest-utils"
fi
echo
pacman -S --noconfirm --needed $virtualbox_install

pack="networkmanager bash-completion \
reflector htop openssh tmux btrfs-progs \
curl wget git rsync unzip unrar p7zip gnu-netcat pv"

pacman -S --noconfirm --needed $pack

# Root password
passwd

# user add & password
while true; do
    clear
    echo -e "add new user"

    printf "\n\nUsername: "
    read -r USER

    printf "New user %s. Continue? [y/N]: " "$USER"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done

useradd -m -g users -G "adm,audio,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash "$USER"
passwd "$USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "ctlos" > /etc/hostname

ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

### rm fsck btrfs
### add keyboard keymap
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap fsck)
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap)
nano /etc/mkinitcpio.conf

mkinitcpio -p linux

pacman -S --noconfirm --needed grub
# pacman -S --noconfirm --needed grub efibootmgr

grub-install /dev/$DISK
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force

grub-mkconfig -o /boot/grub/grub.cfg

systemctl enable NetworkManager
systemctl enable sshd

echo "System Setup Complete"
