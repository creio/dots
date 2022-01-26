#!/bin/bash
# Install script for Arch Linux
# https://raw.githubusercontent.com/creio/dots/master/.bin/creio.sh

# curl -LO git.io/creio.sh
# nano creio.sh
# sh creio.sh

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo "run root" && exit 1
fi

HOST_NAME=rach

read -p "create username: " NEW_USER
read -sp "create password: " PASSWORD

# cfdisk -z /dev/sda
lsblk -d
echo "sda,vda,nvme..?"
read -p "Disk? : " I_DISK
DISK=/dev/$I_DISK
if [[ ! $(lsblk -d | grep $I_DISK) ]]; then
  echo "Error no disk."; exit 1
fi

dd if=/dev/zero of=${DISK} status=progress bs=4096 count=256

# mklabel msdos || mklabel gpt
parted ${DISK} << EOF
mklabel msdos
mkpart primary 1MiB 300MiB
set 1 boot on
mkpart primary 300MiB 100%
quit
EOF

B_DISK=${DISK}1
R_DISK=${DISK}2
S_DISK=${DISK}3
H_DISK=${DISK}4

timedatectl set-ntp true

yes | mkfs.ext4 $R_DISK -L root
yes | mkfs.fat -F32 $B_DISK
# yes | mkfs.ext4 $H_DISK -L home

# mkswap $S_DISK -L swap
# swapon $S_DISK

mount $R_DISK /mnt
mkdir /mnt/boot
mount $B_DISK /mnt/boot
# mkdir /mnt/home
# mount $H_DISK /mnt/home

root_uuid=$(lsblk -no UUID ${R_DISK})

# reflector --verbose -p "http,https" -l 10 --sort score --save /etc/pacman.d/mirrorlist
reflector --verbose -p "http,https" -c "$(curl -s https://ipinfo.io/country)," --sort rate --save /etc/pacman.d/mirrorlist

PKGS=(
base base-devel iwd nano reflector openssh efibootmgr
linux linux-headers
grub
# linux-lts linux-lts-headers
# linux-zen linux-zen-headers
# linux-firmware lvm2
# arch-install-scripts
# amd-ucode intel-ucode
# dhcpcd
wget git rsync gnu-netcat pv bash-completion htop tmux networkmanager
# netctl unzip unrar p7zip zsh
# xorg-apps xorg-server xorg-server-common xorg-xinit xorg-xkill xorg-xrdb xorg-xinput
# xf86-video-intel xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-fbdev xf86-video-dummy
# xf86-video-vesa xf86-video-openchrome xf86-video-sisusb xf86-video-vmware xf86-video-voodoo
# xf86-input-libinput xf86-input-elographics xf86-input-evdev xf86-input-void xf86-input-vmmouse
# sddm plasma-meta kde-system-meta kde-utilities-meta plasma-pa packagekit-qt5
# plasma-desktop plasma-wayland-session egl-wayland
# konsole dolphin ark kate kwalletmanager kdeconnect latte-dock
# brave-bin vlc yay-bin
)

for i in "${PKGS[@]}"; do
  pacstrap /mnt $i 2>&1 | tee -a /tmp/log
done

genfstab -pU /mnt > /mnt/etc/fstab

echo "==== create settings.sh ===="
virt_d=$(systemd-detect-virt)

# sed '1,/^#chroot$/d'
cat <<LOL >/mnt/settings.sh
# reflector --verbose -p "http,https" -l 10 --sort score --save /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf
pacman -Syy --noconfirm

## pass, add user
# usermod -p ${PASSWORD} root
echo "root:$PASSWORD" | chpasswd
useradd -m -g users -G "adm,network,storage,power,wheel" -s /bin/bash "$NEW_USER"
# usermod -p ${PASSWORD} "$NEW_USER"
echo "$NEW_USER:$PASSWORD" | chpasswd

echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo $HOST_NAME > /etc/hostname

#ln -sf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
#timedatectl set-timezone Europe/Moscow
## https://ipapi.co/timezone | http://ip-api.com/line?fields=timezone | https://ipwhois.app/line/?objects=timezone
timedatectl set-timezone $(curl -s https://ipinfo.io/timezone)
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

### rm fsck btrfs
### add keyboard keymap
#nano /etc/mkinitcpio.conf
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap fsck)
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap)

# sed -i "s/^HOOKS=\(.*block\)/HOOKS=\1 lvm2 ventoy/" /etc/mkinitcpio.conf
# sed -i "s/keyboard fsck/keyboard keymap fsck/g" /etc/mkinitcpio.conf
## btrfs rm fsck
# sed -i "s/keyboard fsck/keyboard keymap/g" /etc/mkinitcpio.conf

sed -i "s/^HOOKS=\(.*keyboard\)/HOOKS=\1 keymap/" /etc/mkinitcpio.conf
mkinitcpio -p linux

if [ "$virt_d" = "oracle" ]; then
  echo "Virtualbox"
  pacman -S --noconfirm --needed virtualbox-guest-utils
  systemctl enable vboxservice
  usermod -a -G vboxsf ${NEW_USER}
elif [ "$virt_d" = "vmware" ]; then
  echo
else
  echo "Virt $virt_d"
fi

# bootctl install
# cat <<EOF >/boot/loader/loader.conf
# default arch.conf
# timeout 4
# editor 0
# EOF
# cat <<EOF >/boot/loader/entries/arch.conf
# title Arch Linux
# linux /vmlinuz-linux
# initrd /initramfs-linux.img
# options root=UUID=$root_uuid rw
# EOF

grub-install $DISK
# grub-install --target=x86_64-efi --efi-directory=/boot --bootloader-id=GRUB
# sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

cat <<EOF >/etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       $HOST_NAME.localdomain $HOST_NAME
EOF

# systemctl enable dhcpcd
systemctl enable sshd
systemctl enable NetworkManager

# systemctl enable systemd-networkd
# systemctl enable systemd-resolved

cat <<EOF >/etc/systemd/network/20-ethernet.network
[Match]
Type=ether

[Network]
DHCP=yes
EOF

# systemctl enable sddm

echo "System Setup Complete"
LOL

chmod +x /mnt/settings.sh
arch-chroot /mnt /bin/bash -c /settings.sh 2>&1 | tee -a /tmp/log
rm /mnt/settings.sh

echo "==== Done settings.sh ===="

# swapoff $S_DISK
umount -R /mnt

echo "cat /tmp/log"

echo "==== Finish Him ===="
