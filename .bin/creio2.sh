#!/usr/bin/env bash
# Install script for Arch Linux

# https://raw.githubusercontent.com/creio/dots/master/.bin/creio2.sh

# wget git.io/creio2.sh
# nano creio2.sh


DISK="sdb"


packages=(
base-devel xorg-apps xorg-server xorg-xinit
mesa xf86-video-nouveau
networkmanager network-manager-applet
gtk-engines gtk-engine-murrine xdg-user-dirs qt4 qt5-styleplugins qt5ct
arc-gtk-theme papirus-icon-theme
ttf-dejavu ttf-hack ttf-roboto ttf-ubuntu-font-family ttf-font-awesome
alsa-utils gstreamer pulseaudio pulseaudio-alsa
ffmpeg mpc mpd mpv ncmpcpp streamlink youtube-dl youtube-viewer rofi
bash-completion gtk2-perl rxvt-unicode urxvt-perls slop wmctrl zsh zsh-syntax-highlighting
dunst reflector ranger htop scrot imagemagick compton w3m
curl wget git rsync python-pip unzip unrar p7zip
gvfs gvfs-afc gvfs-goa gvfs-mtp ntfs-3g
gamin thunar thunar-archive-plugin thunar-media-tags-plugin thunar-volman tumbler
gsimplecal redshift xfce4-power-manager numlockx volumeicon
atril audacious cherrytree galculator-gtk2 gimp gparted chromium pepper-flash
gufw nitrogen pavucontrol simplescreenrecorder transmission-gtk viewnior keepassxc veracrypt
openbox lxappearance-obconf obconf
i3-gaps
)

for pack in "${packages[@]}"; do
    pacman --noconfirm --needed -S "$pack"
done



while true; do
    clear
    echo -e "\nWhat would you like your username to be?
    \n\nDo NOT pick the name of an already existing user. This will overwrite their files!"

    printf "\n\nUsername: "
    read -r USER

    printf "You chose %s for your name. Wanna continue? [y/N]: " "$USER"
    read -r answer

    case $answer in
        y*|Y*) break
    esac
done


echo "ctlos" > /etc/hostname
echo
ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
echo
echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen 
echo
locale-gen
echo
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo
echo "KEYMAP=ru" >> /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf
echo
mkinitcpio -p linux
echo
passwd
echo
pacman -Sy --noconfirm --needed grub
grub-install /dev/$DISK
echo
grub-mkconfig -o /boot/grub/grub.cfg
echo
echo


useradd -m -g users -G "adm,audio,floppy,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/zsh "$USER"
passwd "$USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf


systemctl enable NetworkManager
# systemctl start NetworkManager

echo "System Setup Complete"
