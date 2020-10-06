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

R_DISK=${DISK}7
B_DISK=${DISK}5
# H_DISK=${DISK}4
S_DISK=${DISK}6

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
# yes | mkfs.ext4 $H_DISK -L home
yes | mkfs.ext2 $B_DISK -L boot
# yes | mkfs.fat -F32 $B_DISK -L boot

mkswap $S_DISK -L swap
swapon $S_DISK

mount $R_DISK /mnt

mkdir /mnt/{boot,home}
# mkdir -p /mnt/{boot/efi,home}

mount $B_DISK /mnt/boot
# mount $B_DISK /mnt/boot/efi

# mount $H_DISK /mnt/home
### ////// end ext4 mbr & efi ///////


pacman -Sy --noconfirm --needed reflector
reflector -a 12 -l 30 -f 30 -p https --sort rate --save /etc/pacman.d/mirrorlist

PKGS=(
base base-devel linux nano grub reflector
# linux-headers linux-firmware
# dhcpcd netctl iwd openssh networkmanager btrfs-progs
# curl wget git rsync unzip unrar p7zip gnu-netcat pv
# zsh htop tmux
)

for i in "${PKGS[*]}"; do
  pacstrap /mnt $i
done

genfstab -pU /mnt >> /mnt/etc/fstab

chrooter() {
  arch-chroot /mnt /bin/bash -c "${1}"
}

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
else
  echo "Virt $virt_d"
fi

# Root password
usermod -p ${PASSWORD} root

useradd -m -g users -G "adm,audio,log,network,rfkill,scanner,storage,optical,power,wheel" -s /bin/bash "$NEW_USER"
usermod -p ${PASSWORD} "$NEW_USER"
echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

echo "ctlos" > /etc/hostname

ln -svf /usr/share/zoneinfo/Europe/Moscow /etc/localtime

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen

echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

### rm fsck btrfs
### add keyboard keymap
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap fsck)
# HOOKS=(base udev autodetect modconf block filesystems keyboard keymap)

#nano /etc/mkinitcpio.conf
#mkinitcpio -p linux

# pacman -S --noconfirm --needed efibootmgr

grub-install $DISK
# grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=Arch --force

grub-mkconfig -o /boot/grub/grub.cfg

# systemctl enable NetworkManager
systemctl enable systemd-networkd
systemctl enable systemd-resolved

# systemctl enable sshd

echo "System Setup Complete"
LOL

chmod +x /mnt/settings.sh
chrooter /settings.sh
rm /mnt/settings.sh

echo "==== Done settings.sh ===="

swapoff $S_DISK
umount -R /mnt

echo "==== Finish Him ===="
