#!/bin/sh

# Zen Installer Framework version 1.00
#
# Written by Jody James
#
#
#Maintained by Josiah Ward(aka spookykidmm)
#
# This program is free software, provided under the GNU General Public License
# as published by the Free Software Foundation. So feel free to copy, distribute,
# or modify it as you wish.
#
# Special Recognition to Carl Duff, as some code was adapted from the Architect Installer
# Special Recognition to 'angeltoast' as some code was adapted from the Feliz Installer
#
#
# Selecting the Drive
man_partition() {
list=` lsblk -lno NAME,TYPE,SIZE,MOUNTPOINT | grep "disk" `

zenity --info --height=500 width=450 --title="$title" --text "Below is a list of the available drives on your system:\n\n$list"

lsblk -lno NAME,TYPE | grep 'disk' | awk '{print "/dev/" $1 " " $2}' | sort -u > devices.txt
sed -i 's/\<disk\>//g' devices.txt
devices=` awk '{print "FALSE " $0}' devices.txt `

dev=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Select the drive that you want to use for installation." --column Drive --column Info $devices)

# Partitioning
# Allow user to partition using gparted
zenity --question --height=500 --width=450 --title="$title" --text "Do you need to partition $dev?\nSelect 'yes' to open gparted and partition\nthe disk or format partitions if needed.\nThe installer will not format the partitions after this,\nso if your partitions need to be formatted please select yes\nand use gparted to format them now.\nThe installer supports using a seperate /boot /home and /root partition, as well as a swap partition or file."
if [ "$?" = "0" ]
	then gparted
fi

	# Select root partition
	root_part=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Choose a partition to use for the root partition\nWarning, this list shows all available partitions on all available drives.\nPlease choose with care." --column ' ' --column Partitions $(sudo fdisk -l | grep dev | grep -v Disk | awk '{print $1}' | awk '{ printf " FALSE ""\0"$0"\0" }'))
	#mounting root partition
touch root_part.txt
echo $root_part >> root_part.txt
	mount $root_part /mnt

	# Swap partition?
	zenity --question --height=500 --width=450 --title="$title" --text "Do you want to use a swap partition?"
		if [ "$?" = "0" ]
		then swap_part=$(zenity --list  --radiolist --height=500 --width=450 --title="$title" --text="Choose a partition to use for the swap partition\nWarning, this list shows all available partitions on all available drives.\nPlease choose with care." --column ' ' --column 'Partitions' $(sudo fdisk -l | grep dev | grep -v Disk | awk '{print $1}' | awk '{ printf " FALSE ""\0"$0"\0" }'))
		mkswap $swap_part
		swapon $swap_part
		fi
	zenity --question --height=500 --width=450 --title="$title" --text "Would you like to create a 1GB swapfile on root?\nIf you've already mounted a swap partition or don't want swap, select \"No\".\nThis process could take some time, so please be patient."
		if [ "$?" = "0" ]
	 	then swapfile="yes"
		(echo "# Creating swapfile..."
		touch /mnt/swapfile
		dd if=/dev/zero of=/mnt/swapfile bs=1M count=1024
		chmod 600 /mnt/swapfile
		mkswap /mnt/swapfile
		swapon /mnt/swapfile) | zenity --progress --title="$title" --width=450 --pulsate --auto-close --no-cancel
		fi

	# Boot Partition?
	zenity --question --height=500 --width=450 --title="$title" --text "Do you want to use a seperate boot partition?"
		if [ "$?" = "0" ]
		then boot_part=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Please select a partition for /boot. This list shows all available drives on your system, so choose with care." --column ' ' --column Partitions $(sudo fdisk -l | grep dev | grep -v Disk | awk '{print $1}' | awk '{ printf " FALSE ""\0"$0"\0" }'))

		mkdir -p /mnt/boot
		mount $boot_part /mnt/boot

		fi

	# Home Partition?
	zenity --question --height=500 --width=450 --title="$title" --text "Do you want to use a seperate home partition?"
		if [ "$?" = "0" ]
		then home_part=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Select your home partition" --column ' ' --column Partitions $(sudo fdisk -l | grep dev | grep -v Disk | awk '{print $1}' | awk '{ printf " FALSE ""\0"$0"\0" }'))
		# mounting home partition
		mkdir -p /mnt/home
		mount $home_part /mnt/home
		fi
}

auto_partition() {
	list=` lsblk -lno NAME,TYPE,SIZE,MOUNTPOINT | grep "disk" `

	zenity --info --height=500 --width=450 --title="$title" --text "Below is a list of the available drives on your system:\n\n$list"

	lsblk -lno NAME,TYPE | grep 'disk' | awk '{print "/dev/" $1 " " $2}' | sort -u > devices.txt
	sed -i 's/\<disk\>//g' devices.txt
	devices=` awk '{print "FALSE " $0}' devices.txt `

	dev=$(zenity --list  --radiolist --height=500 --width=450 --title="$title" --text "Select the drive that you want to use for installation." --column Drive --column Info $devices)

	zenity --question --height=500 --width=450 --title="$title" --text "Warning! This will erase all data on $dev\!\nAre you sure you want to continue?\nSelect 'Yes' to continue and 'No' to go back."
        yn="$?"
        touch root_part.txt
        if [ "$SYSTEM" = "BIOS" ]
	then echo {$dev}1 >> root_part.txt
	else echo {$dev}2 >> root_part.txt
        fi
	if [ "$yn" = "1" ]
	then partition
	fi

	# Find total amount of RAM
	ram=$(grep MemTotal /proc/meminfo | awk '{print $2/1024}' | sed 's/\..*//')
	# Find where swap partition stops
	num=4000

	if [ "$ram" -gt "$num" ]
		then swap_space=4096
		else swap_space=$ram
	fi

	uefi_swap=$(($swap_space + 513))


	#BIOS or UEFI
    if [ "$SYSTEM" = "BIOS" ]
        then
	       (echo "# Creating Partitions for BIOS..."
	        dd if=/dev/zero of=$dev bs=512 count=1
	        Parted "mklabel msdos"
	        Parted "mkpart primary ext4 1MiB 100%"
	        Parted "set 1 boot on"
	        mkfs.ext4 -F ${dev}1
	        mount ${dev}1 /mnt
		touch /mnt/swapfile
		dd if=/dev/zero of=/mnt/swapfile bs=1M count=${swap_space}
		chmod 600 /mnt/swapfile
		mkswap /mnt/swapfile
		swapon /mnt/swapfile
		swapfile="yes") | zenity --progress --title="$title" --width=450 --pulsate --auto-close --no-cancel
	    else
            	(echo "# Creating Partitions for UEFI..."
            	dd if=/dev/zero of=$dev bs=512 count=1
            	Parted "mklabel gpt"
            	Parted "mkpart primary fat32 1MiB 513MiB"
		Parted "mkpart primary ext4 513MiB 100%"
		Parted "set 1 boot on"
		mkfs.fat -F32 ${dev}1
		mkfs.ext4 -F ${dev}2
		mount ${dev}2 /mnt
		mkdir -p /mnt/boot
		mount ${dev}1 /mnt/boot
		touch /mnt/swapfile
		dd if=/dev/zero of=/mnt/swapfile bs=1M count=${swap_space}
		chmod 600 /mnt/swapfile
		mkswap /mnt/swapfile
		swapon /mnt/swapfile
		swapfile="yes") | zenity --progress --title="$title" --width=450 --pulsate --auto-close --no-cancel
	fi

}

partition() {
	ans=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Would you like to use automatic partitioning or would you like to partition the disk for installation yourself?\nAutomatic Partitioning will completely erase the disk that you select and install Arch." --column Select --column Choice FALSE "Automatic Partitioning" FALSE "Manual Partitioning")

	if [ "$ans" = "Automatic Partitioning" ]
	then auto_partition
	else
	man_partition
	fi

}

configure() {
# Getting Locale
locales=$(cat /etc/locale.gen | grep -v "#  " | sed 's/#//g' | sed 's/ UTF-8//g' | grep .UTF-8 | sort | awk '{ printf "FALSE ""\0"$0"\0" }')

locale=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Select your locale/language.\nThe default is American English 'en_US.UTF-8'." --column Select --column Locale TRUE en_US.UTF-8 $locales)

zenity --question --height=500 --width=450 --title="$title" --text="Would you like to change your keyboard model? The default is pc105"
mod="$?"

if [ "$mod" = "0" ]
then model=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Select your keyboard model" --column Select --column Model $(localectl list-x11-keymap-models | awk '{ printf " FALSE ""\0"$0"\0" }'))
fi

layout=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Select your layout, a two-character country code" --column Select --column Layout $(localectl list-x11-keymap-layouts | awk '{ printf " FALSE ""\0"$0"\0" }'))

zenity --question --height=500 --width=450 --title="$title" --text="Would you like to change your keyboard variant?"
vary="$?"

if [ "$vary" = "0" ]
then variant=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text="Select your preferred variant" --column Select --column Variant $(localectl list-x11-keymap-variants | awk '{ printf " FALSE ""\0"$0"\0" }'))
fi

setxkbmap $layout

if [ "$model" = "0" ]
then setxkbmap -model $model
fi

if [ "$vary" = "0" ]
then setxkbmap -variant $variant
fi
# Getting Timezone
zones=$(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "/" | sed "s/\/.*//g" | sort -ud | sort | awk '{ printf " FALSE ""\0"$0"\0" }')

zone=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Select your country/zone." --column Select --column Zone $zones)

subzones=$(cat /usr/share/zoneinfo/zone.tab | awk '{print $3}' | grep "$zone/" | sed "s/$zone\///g" | sort -ud | sort | awk '{ printf " FALSE ""\0"$0"\0" }')

subzone=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Select your sub-zone." --column Select --column Zone $subzones)

# Getting Clock Preference
clock=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Would you like to use UTC or Local Time\nUTC is recommended unless you are dual booting with Windows." --column Select --column Time TRUE utc FALSE localtime)

# Getting hostname, username, root password, and user password
hname=$(zenity --entry --title="$title" --text "Please enter a hostname for your system.\nIt must be in all lowercase letters." --entry-text "revenge")

username=$(zenity --entry --title="$title" --text "Please enter a username for the new user.\nAgain, in all lowercase." --entry-text "user")
}

vbox() {
graphics=$(lspci | grep -i "vga" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//')
if [[ $(echo $graphics | grep -i 'virtualbox') != "" ]]
	then zenity --question --height=500 --width=450 --title="$title" --text "The Revenge Installer has detected that you are currently running in Virtualbox.\nWould you like to install Virtualbox Utilities to the installed system?"
vb="$?"
fi
}

nvidia() {
graphics=$(lspci | grep -i "vga" | sed 's/.*://' | sed 's/(.*//' | sed 's/^[ \t]*//')
card=$(lspci -k | grep -A 2 -E "(VGA|3D)")
if [[ $(echo $card | grep -i 'nvidia') != "" ]]
	then zenity --question --height=500 --width=450 --title="$title" --text "The Revenge Installer has detected that you are currently running an Nvidia graphics card.\nWould you like to install Proprietary Nvidia graphics drivers to the installed system?"
		if [ "$?" = "0" ]
			then video=$(zenity --list  --checklist --height=500 --width=450 --title="$title" --text "You will need to know what model of NVIDIA graphics card you are using.\nFor NVIDIA 400 series and newer install nvidia and nvidia-libgl.\nFor 8000-9000 or 100-300 series install nvidia-304xx and nvidia-304xx-libgl.\n\nYour current graphics card is:\n$card\n\nSelect the NVIDIA drivers that you would like to install." --column "Select" --column "Driver" FALSE "nvidia nvidia-utils nvidia-settings" FALSE "nvidia-304xx nvidia-304xx-utils nvidia-settings" FALSE "nvidia-340xx nvidia-340xx-utils nvidia-settings" FALSE "nvidia-lts nvidia-settings nvidia-utils" FALSE "nvidia-340xx-lts nvidia-340xx-utils nvidia-settings" FALSE "nvidia-304xx-lts nvidia-304xx-utils nvidia-settings" FALSE "nvidia-dkms" FALSE "nvidia-340xx-dkms" FALSE "nvidia-304xx-dkms")
			else video="mesa xf86-video-nouveau"
		fi
	else video="mesa xf86-video-nouveau"
fi
}

kernel() {
kernel=$(zenity --list  --radiolist --height=500 --width=450 --title="$title" --text "There are several kernels available for the system.\n\nThe most common is the current linux kernel.\nThis kernel is the most up to date, providing the best hardware support.\nHowever, there could be possible bugs in this kernel, despite testing.\n\nThe linux-lts kernel provides a focus on stability.\nIt is based on an older kernel, so it may lack some newer features.\n\nThe linux-hardened kernel is focused on security\nIt contains the Grsecurity Patchset and PaX for increased security.\n\nThe linux-zen kernel is the result of a collaboration of kernel hackers\nto provide the best possible kernel for everyday systems.\n\nPlease select the kernel that you would like to install." --column "Select" --column "Kernel" FALSE linux FALSE linux-lts FALSE linux-hardened FALSE linux-zen)
}

root_password() {
rtpasswd=$(zenity --entry --title="$title" --text "Please enter a root password." --hide-text)
rtpasswd2=$(zenity --entry --title="$title" --text "Please re-enter your root password." --hide-text)
	if [ "$rtpasswd" != "$rtpasswd2" ]
		then zenity --error --height=500 --width=450 --title="$title" --text "The passwords did not match, please try again."
		root_password
	fi
}

changeshell() {
shell=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "What shell would you like to use?" --column Select --column Choice FALSE bash FALSE zsh FALSE fish)
}

user_password() {
userpasswd=$(zenity --entry --title="$title" --text "Please enter a password for $username." --hide-text)
userpasswd2=$(zenity --entry --title="$title" --text "Please re-enter a password for $username." --hide-text)
	if [ "$userpasswd" != "$userpasswd2" ]
		then zenity --error --height=500 --width=450 --title="$title" --text "The passwords did not match, please try again."
		user_password
	fi
}

cups() {
zenity --question --height=500 --width=450 --title="$title" --text "Would you like to install printer support?"
cp="$?"
}

desktop() {
# Choosing Desktop
desktops=$(zenity --list --height=500 --width=450 --title="$title" --radiolist --text "What desktop would you like to install?" --column Select --column Desktop FALSE "gnome" FALSE "gnome gnome-extra" FALSE "plasma" FALSE "plasma kde-applications" FALSE "xfce4" FALSE "xfce4 xfce4-goodies" FALSE "lxde" FALSE "lxqt" FALSE "mate" FALSE "mate mate-extra" FALSE "budgie-desktop" FALSE "cinnamon" FALSE "deepin" FALSE "enlightenment" FALSE "jwm" FALSE "i3-wm i3lock i3status" FALSE "i3-gaps i3status i3lock" FALSE "openbox tint2 openbox-themes" FALSE "mate mate-extra mate-revenge-desktop" FALSE "i3-revenge-desktop" FALSE "Look at more window managers")
if [ "$desktops" = "Look at more window managers" ]
then zenity --list --title="$title" --text="Look at these window managers. You will select the one you want in the next step" --column View --width=450 --height=550 "$(pacman -Ss window manager)"
wm=$(zenity --list --radiolist --height=500 --width=450 --column Select --column WM --title="$title" --radiolist --text="What window manager would you like?" $(pacman -Ssq window manager | awk '{ printf " FALSE ""\0"$0"\0" }'))
fi
}

displaymanager() {
dm=$(zenity --list --title="$title" --radiolist  --height=500 --width=450 --text "What display manager would you like to use?" --column "Select" --column "Display Manager" FALSE "lightdm" FALSE "lxdm" FALSE "sddm" FALSE "gdm" FALSE "default")
}

revengerepo() {
zenity --question --title="$title"  --height=500 --width=450 --text="Would you like to add the revenge_repo to your /etc/pacman.conf?\n The revenge_repo contains a few extra packages, such as spotify and pamac."
rr="$?"
}

pamacaur() {
zenity --question --title="$title" --height=500 --width=450 --text="Would you like to install pamac?\nPamac is a GUI tool to install packages from the repo and the aur"
pa="$?"
}

archuserrepo() {
zenity --question --height=500 --width=450 --title="$title" --text "Would you like to install support for the Arch User Repository 'pacaur'?"
abs="$?"
}

# internet app list
internet_apps() {
zenity --list  --checklist --height=500 --width=450 --title="$title" --text "Select the Internet Applications that You Would Like to Install" --column "Select" --column "Applications" FALSE "chromium " FALSE "midori " FALSE "qupzilla " FALSE "netsurf " FALSE "filezilla " FALSE "opera " FALSE "evolution " FALSE "geary " FALSE "thunderbird " FALSE "transmission-gtk " FALSE "qbittorrent " FALSE "hexchat " > int2.txt
sed -i -e 's/[|]//g' int2.txt
}

# media app list
media_apps() {
zenity --list --checklist  --height=500 --width=450 --title="$title" --text "Select the Media Applications that You Would Like to Install" --column "Select" --column "Applications" FALSE "kodi " FALSE "gimp " FALSE "vlc " FALSE "phonon-qt4-vlc " FALSE "totem " FALSE "parole " FALSE "audacious " FALSE "clementine " FALSE "gthumb " FALSE "shotwell " FALSE "ristretto " FALSE "gpicview " FALSE "brasero " FALSE "audacity " FALSE "simplescreenrecorder " FALSE "xfburn " FALSE "kdenlive " > med2.txt
sed -i -e 's/[|]//g' med2.txt
}

# office app list
office_apps() {
zenity --list  --checklist --height=500 --width=450 --title="$title" --text "Select the Office Applications that You Would Like to Install" --column "Select" --column "Applications" FALSE "calligra " FALSE "abiword " FALSE "gnumeric " FALSE "pdfmod " FALSE "evince " FALSE "epdfview " FALSE "calibre " FALSE "fbreader " > off2.txt
sed -i -e 's/[|]//g' off2.txt
}

# utility app list
utility_apps() {
zenity --list --checklist --height=500 --width=450 --title="$title" --text "Select the Utility Applications that You Would Like to Install" --column "Select" --column "Applications" FALSE "htop " FALSE "terminator " FALSE "gnome-disk-utility " FALSE "gparted " FALSE "synapse " FALSE "virtualbox " FALSE "gufw " FALSE "redshift " FALSE "leafpad " FALSE "geany " FALSE "parcellite " FALSE "grsync " FALSE "guake " FALSE "ntfs-3g " FALSE "btrfs-progs " FALSE "gptfdisk " > utils.txt
sed -i -e 's/[|]//g' utils.txt
}

# allowing user to select extra applications
pacman -Syy
libreoffice() {
zenity --question --height=500 --width=450 --title="$title" --text="Would you like to install libreoffice, an open source ms office alternative?"
lbr="$?"
if [ "$lbr" = "0" ]
then lover=$(zenity --list --radiolist --height=500 --width=450 --text="Libreoffice-fresh is the newest up-to-date version of libreoffice, while still is less frequently updated" --column Select --column Version FALSE "fresh" FALSE "still")
lolang=$(zenity --list --radiolist --height=500 --width=450 --column Select --column Langpack $(pacman -Ssq libreoffice-$lover lang | awk '{ printf " FALSE ""\0"$0"\0" }'))
fi
}

firefox() {
zenity --question --height=500 --width=450 --title="$title" --text="Would you like to install Firefox, a browser by the Mozilla foundation?"
frf="$?"
if [ "$frf" = "0" ]
then fflang=$(zenity --list --radiolist --height=500 --width=450 --column Select --column Langpack $(pacman -Ssq firefox lang  | awk '{ printf " FALSE ""\0"$0"\0" }'))
fi
}

installapps() {
extra=$(zenity --list --height=500 --width=450 --title="$title" --radiolist --text "If you would like to select more applications to install,\nChoose the category from the
list below.\nWhen you are finished selecting applications\nin each category you will be returned to this menu.\nThen simply select 'finished' when you are
finished." --column Select --column Category FALSE internet FALSE media FALSE office FALSE utilities FALSE finished)

if [ "$extra" = "internet" ]
	then internet_apps;installapps
elif [ "$extra" = "media" ]
	then media_apps;installapps
elif [ "$extra" = "office" ]
	then office_apps;installapps
elif [ "$extra" = "utilities" ]
	then utility_apps;installapps
fi

}

# bootloader?
bootloader() {
lsblk -lno NAME,TYPE | grep 'disk' | awk '{print "/dev/" $1 " " $2}' | sort -u > devices.txt
sed -i 's/\<disk\>//g' devices.txt
devices=` awk '{print "FALSE " $0}' devices.txt `

grub=$(zenity --question --height=500 --width=450 --title="$title" --text "Would you like to install the bootloader?\nThe answer to this is usually yes,\nunless you are dual-booting and plan to have another system handle\nthe boot process.")
grb="$?"
if [ "$grb" = "0" ]
	then grub_device=$(zenity --list --radiolist --height=500 --width=450 --title="$title" --text "Where do you want to install the bootloader?" --column Select --column Device $devices)
fi
}

# Installation
installing() {
zenity --question --height=500 --width=450 --title="$title" --text "Please click yes to begin installation.\nClick no to abort installation.\nAll of the packages will be downloaded fresh, so installation\nmay take a few minutes."

if [ "$?" = "1" ]
	then exit
else (
# sorting pacman mirrors
echo "# Sorting fastest pacman mirrors..."
reflector --verbose -l 50 -p http --sort rate --save /etc/pacman.d/mirrorlist

# updating pacman cache
echo "# Updating Pacman Cache..."
pacman -Syy
arch_chroot "pacman -Syy"

#installing base
echo "# Installing Base..."
if [ "$kernel" = "linux" ]
	then pacstrap /mnt base base-devel
elif [ "$kernel" = "linux-lts" ]
	then pacstrap /mnt $(pacman -Sqg base | sed 's/^\(linux\)$/\1-lts/') base-devel
elif [ "$kernel" = "linux-hardened" ]
	then pacstrap /mnt $(pacman -Sqg base | sed 's/^\(linux\)$/\1-hardened/') base-devel
elif [ "$kernel" = "linux-zen" ]
	then pacstrap /mnt $(pacman -Sqg base | sed 's/^\(linux\)$/\1-zen/') base-devel

fi

#generating fstab
echo "# Generating File System Table..."
genfstab -p /mnt >> /mnt/etc/fstab
if grep -q "/mnt/swapfile" "/mnt/etc/fstab"; then
sed -i '/swapfile/d' /mnt/etc/fstab
echo "/swapfile		none	swap	defaults	0	0" >> /mnt/etc/fstab
fi

# installing video and audio packages
echo "# Installing Desktop, Sound, and Video Drivers..."
pacstrap /mnt mesa xorg-server xorg-apps xorg-xinit xorg-twm xterm xorg-drivers alsa-utils pulseaudio pulseaudio-alsa xf86-input-synaptics xf86-input-keyboard xf86-input-mouse xf86-input-libinput intel-ucode b43-fwcutter networkmanager nm-connection-editor network-manager-applet polkit-gnome ttf-dejavu gnome-keyring xdg-user-dirs gvfs

# virtualbox
if [ "$vb" = "0" ]
	then
	if [ "$kernel" = "linux" ]
		then pacstrap /mnt virtualbox-guest-modules-arch virtualbox-guest-utils
        	echo -e "vboxguest\nvboxsf\nvboxvideo" > /mnt/etc/modules-load.d/virtualbox.conf
	elif [ "$kernel" = "linux-lts" ]
		then pacstrap /mnt virtualbox-guest-dkms virtualbox-guest-utils linux-lts-headers
		echo -e "vboxguest\nvboxsf\nvboxvideo" > /mnt/etc/modules-load.d/virtualbox.conf
	elif [ "$kernel" = "linux-hardened" ]
		then pacstrap /mnt virtualbox-guest-dkms virtualbox-guest-utils linux-hardened-headers
		echo -e "vboxguest\nvboxsf\nvboxvideo" > /mnt/etc/modules-load.d/virtualbox.conf
	elif [ "$kernel" = "linux-zen" ]
		then pacstrap /mnt virtualbox-guest-dkms virtualbox-guest-utils linux-zen-headers
		echo -e "vboxguest\nvboxsf\nvboxvideo" > /mnt/etc/modules-load.d/virtualbox.conf
	fi
fi
echo "25"

# installing chosen desktop
if [ "$desktops" = "Look at more window managers" ]
then pacstrap /mnt $wm
else pacstrap /mnt $desktops
fi

# cups
if [ "$cp" = "0" ]
	then pacstrap /mnt ghostscript gsfonts system-config-printer gtk3-print-backends cups cups-pdf cups-filters
arch_chroot "systemctl enable org.cups.cupsd.service"
fi

# enabling network manager
arch_chroot "systemctl enable NetworkManager"
echo "50"
# adding revenge_repo
if [ "$rr" = "0"  ]
then echo "[revenge_repo]" >> /mnt/etc/pacman.conf;echo "SigLevel = Optional TrustAll" >> /mnt/etc/pacman.conf;echo "Server = https://raw.github.com/obrevenge/revenge_repo/master/x86_64" >> /mnt/etc/pacman.conf;echo "Server = https://downloads.sourceforge.net/project/revenge-repo/revenge_repo/x86_64" >> /mnt/etc/pacman.conf;echo "Server = ftp://ftp.heanet.ie/mirrors/sourceforge/r/re/revenge-repo/revenge_repo/x86_64" >> /mnt/etc/pacman.conf
arch_chroot "sudo pacman -Syy"
fi

# installing pamac-aur
if [ "$pa" = "0" ]
then echo "[spooky_aur]" >> /mnt/etc/pacman.conf;echo "SigLevel = Optional TrustAll" >> /mnt/etc/pacman.conf;echo "Server = https://raw.github.com/spookykidmm/spooky_aur/master/x86_64" >> /mnt/etc/pacman.conf
arch_chroot "pacman -Syy"
arch_chroot "pacman -S --noconfirm pamac-aur"
fi

# AUR
if [ "$abs" = "0" ]
	then echo "[spooky_aur]" >> /mnt/etc/pacman.conf;echo "SigLevel = Optional TrustAll" >> /mnt/etc/pacman.conf;echo "Server = https://raw.github.com/spookykidmm/spooky_aur/master/x86_64" >> /mnt/etc/pacman.conf
    arch_chroot "pacman -Syy"
	arch_chroot "pacman -S --noconfirm pacaur"

fi
echo "75"

# installing bootloader
if [ "$grb" = "0" ]
	then if [ "$SYSTEM" = 'BIOS' ]
		then echo "# Installing Bootloader..."
		pacstrap /mnt grub
		arch_chroot "grub-install --target=i386-pc $grub_device"
		arch_chroot "grub-mkconfig -o /boot/grub/grub.cfg"
	else
		echo "# Installing Bootloader..."


		if [ "$ans" = "Automatic Partitioning" ]
			then root_part=${dev}2
		fi

		[[ $(echo $root_part | grep "/dev/mapper/") != "" ]] && bl_root=$root_part \
		|| bl_root=$"PARTUUID="$(blkid -s PARTUUID ${root_part} | sed 's/.*=//g' | sed 's/"//g')

		arch_chroot "bootctl --path=/boot install"
		echo -e "default  Arch\ntimeout  10" > /mnt/boot/loader/loader.conf
		[[ -e /mnt/boot/initramfs-linux.img ]] && echo -e "title\tArch Linux\nlinux\t/vmlinuz-linux\ninitrd\t/initramfs-linux.img\noptions\troot=${bl_root} rw" > /mnt/boot/loader/entries/Arch.conf
		[[ -e /mnt/boot/initramfs-linux-lts.img ]] && echo -e "title\tArchLinux LTS\nlinux\t/vmlinuz-linux-lts\ninitrd\t/initramfs-linux-lts.img\noptions\troot=${bl_root} rw" > /mnt/boot/loader/entries/Arch-lts.conf
		[[ -e /mnt/boot/initramfs-linux-hardened.img ]] && echo -e "title\tArch Linux hardened\nlinux\t/vmlinuz-linux-hardened\ninitrd\t/initramfs-linux-hardened.img\noptions\troot=${bl_root} rw" > /mnt/boot/loader/entries/Arch-hardened.conf
		[[ -e /mnt/boot/initramfs-linux-zen.img ]] && echo -e "title\tArch Linux Zen\nlinux\t/vmlinuz-linux-zen\ninitrd\t/initramfs-linux-zen.img\noptions\troot=${bl_root} rw" > /mnt/boot/loader/entries/Arch-zen.conf
		fi
fi

# running mkinit
echo "# Running mkinitcpio..."
arch_chroot "mkinitcpio -p $kernel"


# installing chosen software
echo "# Installing chosen software packages..."
# Making Variables from Applications Lists
int=` cat int2.txt `
med=` cat med2.txt `
off=` cat off2.txt `
utils=` cat utils.txt `


# Installing Selecting Applications
arch_chroot "pacman -Syy"
arch_chroot "pacman -S --noconfirm $int $med $off $utils"
if [ "$lbr" = "0" ]
then arch_chroot "pacman -S --noconfirm libreoffice-$lover $lolang"
fi
if [ "$frf" = "0" ]
then arch_chroot "pacman -S --noconfirm firefox  $fflang"
fi
#root password
echo "# Setting root password..."
touch .passwd
echo -e "$rtpasswd\n$rtpasswd2" > .passwd
arch_chroot "passwd root" < .passwd >/dev/null
rm .passwd

#adding user
echo "# Making new user..."
arch_chroot "useradd -m -g users -G adm,lp,wheel,power,audio,video -s /bin/bash $username"
touch .passwd
echo -e "$userpasswd\n$userpasswd2" > .passwd
arch_chroot "passwd $username" < .passwd >/dev/null
rm .passwd

#setting locale
echo "# Generating Locale..."
echo "LANG=\"${locale}\"" > /mnt/etc/locale.conf
echo "${locale} UTF-8" > /mnt/etc/locale.gen
arch_chroot "locale-gen"
export LANG=${locale}

#setting keymap
mkdir -p /mnt/etc/X11/xorg.conf.d/
echo -e 'Section "InputClass"\n\tIdentifier "system-keyboard"\n\tMatchIsKeyboard "on"\n\tOption "XkbLayout" "'$layout'"\n\tOption "XkbModel" "'$model'"\n\tOption "XkbVariant" ",'$variant'"\n\tOption "XkbOptions" "grp:alt_shift_toggle"\nEndSection' > /mnt/etc/X11/xorg.conf.d/00-keyboard.conf

#setting timezone
echo "# Setting Timezone..."
arch_chroot "rm /etc/localtime"
arch_chroot "ln -s /usr/share/zoneinfo/${zone}/${subzone} /etc/localtime"

#setting hw clock
echo "# Setting System Clock..."
arch_chroot "hwclock --systohc --$clock"

#setting hostname
echo "# Setting Hostname..."
arch_chroot "echo $hname > /etc/hostname"

# setting sudo permissions
echo "%wheel ALL=(ALL) ALL" >> /mnt/etc/sudoers

# selecting shell
if [ "$shell" = "zsh" ]
then arch_chroot "sudo pacman -S --noconfirm zsh zsh-syntax-highlighting zsh-completions grml-zsh-config;chsh -s /usr/bin/zsh $username"
else arch_chroot "sudo pacman -S --noconfirm $shell;chsh -s /usr/bin/$shell"
fi

# starting desktop manager
if [ "$dm"  = "default" ]
then if [ "$desktop" == "gnome" ]
	then arch_chroot "systemctl enable gdm.service"
	elif [ "$desktop" = "budgie-desktop" ]
	then pacstrap /mnt lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter gnome-control-center gnome-backgrounds;arch_chroot "systemctl enable lightdm.service"
	elif [ "$desktop" = "lxde" ]
	then pacstrap /mnt lxdm-gtk3;arch_chroot "systemctl enable lxdm.service"
	elif [ "$desktop" == "plasma" ]
	then pacstrap /mnt sddm;arch_chroot "systemctl enable sddm.service"
	else pacstrap /mnt lightdm lightdm-gtk-greeter-settings lightdm-gtk-greeter
	arch_chroot "systemctl enable lightdm.service"
	fi
elif [ "$dm" = "lightdm" ]
then pacstrap /mnt lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings;arch_chroot "systemctl enable lightdm.service"
else pacstrap /mnt $dm;arch_chroot "systemctl enable $dm.service"
fi

# unmounting partitions
umount -R /mnt
echo "100"
echo "# Installation Finished!"
) | zenity --progress --percentage=0 --title="$title" --width=450 --no-cancel
fi
}

# execution
# System Detection
if [[ -d "/sys/firmware/efi/" ]]; then
      SYSTEM="UEFI"
      else
      SYSTEM="BIOS"
fi


# Setting variables
title="Zen Installer Framework 1.00 $SYSTEM"

# Adapted from AIS. An excellent bit of code!
arch_chroot() {
    arch-chroot /mnt /bin/bash -c "${1}"
}

# Adapted from Feliz Installer
Parted() {
	parted --script $dev "$1"
}
# Greeting the user
zenity --question --height=50--title="$title" --text "Welcome to the Zen Arch Installer.\n\nNext you will be prompted with a series of questions that will\nguide you through installing Arch Linux.\nYou will be asked if you want to use manual or auto partitioning.\nIf you select auto partitioning the drive that you select will be completely deleted\nand Arch will be installed. If you select manual, you will have the opportunity to partition the disk yourself\nand select which partitons to use for installation.\nClick 'yes' to begin or 'no' to exit."

if [ "$?" = "1" ]
	then exit
fi

partition
configure
root_password
user_password
changeshell
kernel
vbox
#nvidia
revengerepo
pamacaur
archuserrepo
cups
displaymanager
desktop
firefox
libreoffice
installapps
bootloader
installing
