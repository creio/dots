#!/usr/bin/bash
# Install script for Arch Linux
# https://raw.githubusercontent.com/creio/dots/master/.bin/creio.sh

# curl -OL git.io/creio.sh
# nano creio.sh
# sh creio.sh

# Check for root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root." >&2
   echo "Try 'sudo sh'"
   echo ""
   exit 1
fi

NEW_USER=cretm

PASSWORD=$(/usr/bin/openssl passwd -crypt "$NEW_USER")

DISK=/dev/sda

B_DISK=${DISK}1
R_DISK=${DISK}2

timedatectl set-ntp true

yes | mkfs.ext4 $R_DISK -L root
R_PUID=$(blkid -s PARTUUID -o value ${R_DISK})
yes | mkfs.fat -F32 $B_DISK -L boot

mount $R_DISK /mnt
mkdir -p /mnt/boot
mount $B_DISK /mnt/boot


pacman -Sy --noconfirm --needed reflector
reflector -a 12 -l 30 -f 30 -p https --sort rate --save /etc/pacman.d/mirrorlist

PKGS=(
base base-devel linux nano lvm2 reflector
linux-headers linux-firmware
dhcpcd iwd openssh
)

for i in "${PKGS[*]}"; do
  pacstrap /mnt $i
done

genfstab -pU /mnt >> /mnt/etc/fstab

echo "==== create settings.sh ===="
virt_d=$(systemd-detect-virt)

cat <<LOL >/mnt/settings.sh
reflector -a 12 -l 30 -f 30 -p https --sort rate --save /etc/pacman.d/mirrorlist
pacman-key --init
pacman-key --populate

sed -i "/\[multilib\]/,/Include/"'s/^#//' /etc/pacman.conf

pacman -Syy --noconfirm

if [ "$virt_d" = "oracle" ]; then
  echo "Virtualbox"
  pacman -S --noconfirm --needed virtualbox-guest-utils virtualbox-guest-dkms
  systemctl enable vboxservice
elif [ "$virt_d" = "vmware" ]; then
  echo
else
  echo "Virt $virt_d"
fi

# Root password
usermod -p ${PASSWORD} root

useradd -m -g users -G "log,network,storage,power,wheel" -s /bin/bash "$NEW_USER"
usermod -p ${PASSWORD} "$NEW_USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "ctlos" > /etc/hostname

ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime
hwclock --systohc --utc

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

bootctl install
cat <<EOF >/boot/loader/entries/arch.conf
title      Arch
linux      /vmlinuz-linux
initrd     /initramfs-linux.img
options    root=PARTUUID=${R_PUID} rw
EOF

# systemctl enable dhcpcd
# systemctl enable NetworkManager

cat <<EOF >/etc/systemd/network/20-ethernet.network
[Match]
Name=en*
Name=eth*

[Network]
DHCP=yes
EOF

systemctl enable systemd-networkd
systemctl enable systemd-resolved

# systemctl enable sshd

echo "System Setup Complete"
LOL

chmod +x /mnt/settings.sh
arch-chroot /mnt /bin/bash -c /settings.sh
rm /mnt/settings.sh

echo "==== Done settings.sh ===="

umount -R /mnt

echo "==== Finish Him ===="
