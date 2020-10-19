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
   exit 1
fi

NEW_USER=creio

PASSWORD=$(/usr/bin/openssl passwd -crypt "$NEW_USER")

# cfdisk -z /dev/sda
DISK=/dev/sdb

R_DISK=${DISK}1
B_DISK=${DISK}2
S_DISK=${DISK}3
H_DISK=${DISK}4

timedatectl set-ntp true


### ////// btrfs mbr ///////
# mkfs.btrfs -f -L "root" $R_DISK
# mkfs.ext2 -L "boot" $B_DISK
# mkswap -L "swap" $S_DISK

# mount $R_DISK /mnt
# btrfs subvolume create /mnt/@
# btrfs subvolume create /mnt/@home
# umount /mnt

# mount -o subvol=@,compress=lzo,relatime,space_cache,autodefrag $R_DISK /mnt
# mkdir /mnt/{boot,home}
# mount $B_DISK /mnt/boot
# mount -o subvol=@home,compress=lzo,relatime,space_cache,autodefrag $R_DISK /mnt/home
# # // ssd trim
# # mount -o subvol=@,compress=lzo,ssd,discard,relatime,space_cache,autodefrag $R_DISK /mnt
# # mount -o subvol=@home,compress=lzo,ssd,discard,relatime,space_cache,autodefrag $R_DISK /mnt/home
# swapon $S_DISK
### ////// end btrfs mbr ///////


### ////// ext4 mbr & efi ///////
yes | mkfs.ext4 $R_DISK -L root
yes | mkfs.ext2 $B_DISK -L boot
# yes | mkfs.fat -F32 $B_DISK -L boot
yes | mkfs.ext4 $H_DISK -L home

mkswap $S_DISK -L swap
swapon $S_DISK

mount $R_DISK /mnt

mkdir /mnt/{boot,home}
# mkdir -p /mnt/{boot/efi,home}

mount $B_DISK /mnt/boot
# mount $B_DISK /mnt/boot/efi

mount $H_DISK /mnt/home
### ////// end ext4 mbr & efi ///////


pacman -Sy --noconfirm --needed reflector
reflector -a 12 -l 30 -f 30 -p https --sort rate --save /etc/pacman.d/mirrorlist

PKGS=(
base base-devel linux nano grub reflector nano openssh
linux-headers linux-firmware lvm2
# amd-ucode intel-ucode
# dhcpcd iwd
wget git rsync gnu-netcat pv
netctl unzip unrar p7zip zsh htop tmux
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
  pacman -S --noconfirm --needed virtualbox-guest-utils-nox nfs-utils
  systemctl enable vboxservice
  systemctl enable rpcbind
  usermod -a -G vboxsf ${NEW_USER}
elif [ "$virt_d" = "vmware" ]; then
  echo
else
  echo "Virt $virt_d"
fi

# pacman -S --noconfirm --needed efibootmgr

grub-install $DISK
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force

sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg

# systemctl enable dhcpcd
# systemctl enable sshd

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

echo "System Setup Complete"
LOL

chmod +x /mnt/settings.sh
arch-chroot /mnt /bin/bash -c /settings.sh
rm /mnt/settings.sh

echo "==== Done settings.sh ===="

swapoff $S_DISK
umount -R /mnt

echo "==== Finish Him ===="
