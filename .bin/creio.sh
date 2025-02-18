#!/bin/bash
# Install script archlinux
# https://raw.githubusercontent.com/creio/dots/master/.bin/creio.sh

# curl -LO git.io/creio.sh
# nano creio.sh
# sudo sh creio.sh

HOST_NAME=rach
# btrfs || ext4
FS_TYPE=ext4
# systemd-boot || grub-efi || grub
BOOT_LOADER=grub

# Check for root
if [[ $EUID -ne 0 ]]; then
  echo "run root"; exit 1
fi

read -p "create username: " NEW_USER
read -sp "create password: " PASSWORD
echo
read -sp "confirm password: " C_PASSWORD
if [[ "$PASSWORD" != "$C_PASSWORD" ]]; then
  echo "Error: incorrect password"; exit 1
fi

# cfdisk -z /dev/sda
lsblk -d
echo "sda,vda,nvme..?"
read -p "Disk?: " I_DISK
DISK=/dev/$I_DISK
if [[ ! $(lsblk -d | grep $I_DISK) ]]; then
  echo "Error: incorrect disk."; exit 1
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

## swap
# mkswap $S_DISK -L swap
# swapon $S_DISK

if [[ "$FS_TYPE" == "btrfs" ]]; then
  mkfs.btrfs -f -L "root" $R_DISK
  yes | mkfs.fat -F32 $B_DISK
  mount $R_DISK /mnt
  btrfs subvolume create /mnt/@
  btrfs subvolume create /mnt/@home
  btrfs subvolume create /mnt/@snapshots
  umount -R /mnt
  mount -o compress=zstd,noatime,subvol=@ $R_DISK /mnt
  mkdir -p /mnt/{boot,home,.snapshots}
  mount -o compress=zstd,noatime,subvol=@home $R_DISK /mnt/home
  mount -o compress=zstd,subvol=@snapshots $R_DISK /mnt/.snapshots
  mount $B_DISK /mnt/boot
  if [[ "$BOOT_LOADER" == "systemd-boot" ]]; then
    systemd_flags="rootflags=subvol=/@ rootfstype=btrfs"
  else
    systemd_flags=""
  fi
elif [[ "$FS_TYPE" == "ext4" ]]; then
  yes | mkfs.ext4 $R_DISK -L root
  yes | mkfs.fat -F32 $B_DISK
  # yes | mkfs.ext4 $H_DISK -L home
  mount $R_DISK /mnt
  mkdir /mnt/boot
  mount $B_DISK /mnt/boot
  # mkdir /mnt/home
  # mount $H_DISK /mnt/home
else
  echo "fs type"; exit 1
fi

root_uuid=$(lsblk -no UUID ${R_DISK})

## https://ipapi.co/timezone | http://ip-api.com/line?fields=timezone | https://ipwhois.app/line/?objects=timezone
time_zone=$(curl -s https://ipinfo.io/timezone)
timedatectl set-timezone $time_zone

# reflector --verbose -p "http,https" -l 10 --sort score --save /etc/pacman.d/mirrorlist
reflector --verbose -p "http,https" -c "$(curl -s https://ipinfo.io/country)," --sort rate --save /etc/pacman.d/mirrorlist

PKGS=(
base base-devel nano reflector openssh
linux linux-headers
# linux-firmware lvm2
# linux-lts linux-lts-headers
# linux-zen linux-zen-headers
# btrfs-progs
grub
# efibootmgr
# os-prober
# arch-install-scripts
# amd-ucode intel-ucode
# dhcpcd netctl iwd
networkmanager
wget git rsync gnu-netcat pv bash-completion bottom tmux zsh
zip unzip unrar p7zip gzip bzip2 zlib
xorg-apps xorg-server xorg-server-common xorg-xinit xorg-xkill xorg-xrdb xorg-xinput
# xf86-video-intel xf86-video-amdgpu xf86-video-ati xf86-video-nouveau xf86-video-fbdev xf86-video-dummy
xf86-video-vesa xf86-video-openchrome xf86-video-sisusb xf86-video-vmware xf86-video-voodoo
xf86-input-libinput xf86-input-elographics xf86-input-evdev xf86-input-void xf86-input-vmmouse
pulseaudio pulseaudio-alsa alsa-utils pavucontrol
# pulseaudio-equalizer pulseaudio-bluetooth
# pipewire pipewire-audio pipewire-pulse lib32-pipewire pipewire-alsa
# gst-plugin-pipewire pipewire-media-session
# wireplumber
sddm yay-bin
# plasma-meta kde-system-meta kde-utilities-meta plasma-pa packagekit-qt5
# plasma-desktop plasma-wayland-session egl-wayland
# konsole dolphin ark kate kwalletmanager kdeconnect latte-dock
# brave-bin vlc
)

for i in "${PKGS[@]}"; do
  pacstrap /mnt $i 2>&1 | tee -a /tmp/log
done

genfstab -pU /mnt > /mnt/etc/fstab

echo "==== create settings.sh ===="
virt_d=$(systemd-detect-virt)
cat <<LOL >/mnt/settings.sh
pacman-key --init
pacman-key --populate

sed -i '/Color/s/^#//g' /etc/pacman.conf
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
ln -sf /usr/share/zoneinfo/$time_zone /etc/localtime
hwclock --systohc --utc
timedatectl set-ntp true

echo "en_US.UTF-8 UTF-8" > /etc/locale.gen
echo "ru_RU.UTF-8 UTF-8" >> /etc/locale.gen
locale-gen
echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
echo "KEYMAP=ru" > /etc/vconsole.conf
echo "FONT=cyr-sun16" >> /etc/vconsole.conf

### rm fsck btrfs && add keyboard keymap
# sed -i "s/^HOOKS=\(.*block\)/HOOKS=\1 lvm2 ventoy/" /etc/mkinitcpio.conf
# sed -i "s/keyboard fsck/keyboard keymap fsck/g" /etc/mkinitcpio.conf
## btrfs rm fsck
if [[ "$FS_TYPE" == "btrfs" ]]; then
  sed -i "s/keyboard fsck/keyboard keymap/g" /etc/mkinitcpio.conf
else
  sed -i "s/^HOOKS=\(.*keyboard\)/HOOKS=\1 keymap/" /etc/mkinitcpio.conf
fi
mkinitcpio -P

if [[ "$virt_d" == "oracle" ]]; then
  echo "Virtualbox"
  pacman -S --noconfirm --needed virtualbox-guest-utils
  systemctl enable vboxservice
  usermod -a -G vboxsf ${NEW_USER}
elif [[ "$virt_d" == "vmware" ]]; then
  echo
else
  echo "Virt $virt_d"
fi

if [[ "$BOOT_LOADER" == "grub-efi" ]]; then
grub-install --target=x86_64-efi --efi-directory=/boot
# sed -i -e 's/^GRUB_TIMEOUT=.*$/GRUB_TIMEOUT=0/' /etc/default/grub
sed -i '/GRUB_DISABLE_OS_PROBER/s/^#//g' /etc/default/grub
grub-mkconfig -o /boot/grub/grub.cfg
elif [[ "$BOOT_LOADER" == "grub" ]]; then
grub-install $DISK
grub-mkconfig -o /boot/grub/grub.cfg
else
bootctl install
cat <<EOF >/boot/loader/loader.conf
default arch.conf
timeout 4
editor 0
EOF
cat <<EOF >/boot/loader/entries/arch.conf
title Rach Linups
linux /vmlinuz-linux
initrd /initramfs-linux.img
options root=UUID=$root_uuid $systemd_flags rw
EOF
fi

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
Name=en*
Name=eth*

[Network]
DHCP=yes
EOF

cat <<EOF >/etc/systemd/network/20-wireless.network
[Match]
Type=wlan

[Network]
DHCP=yes
EOF

systemctl enable sddm

echo "System Setup Complete"
LOL

chmod +x /mnt/settings.sh
arch-chroot /mnt /bin/bash -c /settings.sh 2>&1 | tee -a /tmp/log
rm /mnt/settings.sh

echo "==== Done settings.sh ===="

if read -re -p "arch-chroot /mnt? [y/N]: " ans && [[ $ans == 'y' || $ans == 'Y' ]]; then
  arch-chroot /mnt
else
  umount -R /mnt
fi
# swapoff $S_DISK

echo "less /tmp/log"

echo "==== Finish Him ===="
