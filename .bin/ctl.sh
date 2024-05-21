#!/usr/bin/bash

version="1.0.0"

main_color="#778dd3"
warning_color="#ff0000"

export BORDER_FOREGROUND="$main_color"
export GUM_CONFIRM_SELECTED_BACKGROUND="$main_color"
export GUM_CHOOSE_CURSOR_FOREGROUND="$main_color"
export GUM_CHOOSE_SELECTED_FOREGROUND="$main_color"
export GUM_INPUT_CURSOR_FOREGROUND="$main_color"
export GUM_FILTER_INDICATOR_FOREGROUND="$main_color"
export FOREGROUND="#a9b1d6"

Welcome() {
    gum confirm "$(gum style --border normal --margin '1' --padding '1 2' "$(gum style --foreground "$main_color" '             *
            /|\
           //|\\
          ///|\\\
         ////|\\\\
        /////|\\\\\
       //////|\\\\\\
      /////// \\\\\\\
     ///////   \\\\\\\
    ///////     \\\\\\\
          """""""')" "" "Ctlos installation... ready?" "" "$(gum style --foreground "$FOREGROUND" "ctl.sh version: $version")")" && CONTINUE=true
    if [[ $CONTINUE != "true" ]]; then
        echo "Exiting. Good bay!"
        exit
    fi
}

Timezone() {
    timezone=$(timedatectl list-timezones | gum filter --placeholder "select a timezone")
}

Keymap() {
    keymap=$(localectl list-keymaps | gum filter --placeholder "select a keymap")
}

Locale() {
    locale=$(cat /usr/share/ctlos/locales | gum filter --placeholder "select a locale")
}

Username() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Please enter your username"
    username=$(gum input --placeholder "Please enter your username")
}

Password() {
    matches="false"
    passwrong="false"
    while [[ "$matches" == "false" ]]; do
        clear
        if [[ "$passwrong" == "true" ]]; then
            gum style --border normal --margin "1" --padding "1 2" "Passwords did not match, please type the password again"
        else
            gum style --border normal --margin "1" --padding "1 2" "Now enter your password"
        fi
        password=$(gum input --password --placeholder "Please enter a password")
        clear
        gum style --border normal --margin "1" --padding "1 2" "Verify your password"
        password_verif=$(gum input --password --placeholder "Type your password again")
        if [[ "$password" == "$password_verif" ]]; then
            matches="true"
        else
            passwrong="true"
        fi
    done
    crypt_password=$(openssl passwd -crypt $password)
}

RootPassword() {
    clear
    different_root_password=true
    gum confirm "$(gum style --border normal --margin '1' --padding '1 2' 'Use same password for root?')" && different_root_password=false
    if [[ $different_root_password != "true" ]]; then
        root_password=$password # set root password same as user password
    else
        root_matches="false"
        root_passwrong="false"
        while [[ "$root_matches" == "false" ]]; do
            clear
            if [[ "$root_passwrong" == "true" ]]; then
                gum style --border normal --margin "1" --padding "1 2" "Passwords did not match, please type the root password again"
            else
                gum style --border normal --margin "1" --padding "1 2" "Now enter your root password"
            fi
            root_password=$(gum input --password --placeholder "Please enter a root password")
            clear
            gum style --border normal --margin "1" --padding "1 2" "Verify your root password"
            root_password_verif=$(gum input --password --placeholder "Type your root password again")
            if [[ "$root_password" == "$root_password_verif" ]]; then
                root_matches="true"
            else
                root_passwrong="true"
            fi
        done
    fi
    crypt_root_password=$(openssl passwd -crypt ${root_password})
}

Shell() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Select a default shell"
    shell=$(gum choose --limit 1 fish zsh bash)

    # TODO: remove when jade works all the time
    if [[ "$shell" == "fish" ]]; then
        fish_pkg="\"fish\""
    else
        fish_pkg=""
    fi
}

Hostname() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Please enter a hostname"
    hostname=$(gum input --placeholder "Please enter a hostname")
}

AutoDisk() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Please select the disk to install to" "$(gum style --foreground "$warning_color" 'WARNING: This will erease the whole disk')"
    disk_dev=$(lsblk -pdo name | grep -v zram | grep -v NAME | grep -v loop | grep -v sr | gum choose --limit 1)
    disk=$(echo $disk_dev | awk '{ print substr ($0, 6 ) }')
}

UEFICheck() {
    is_uefi=$([ -d /sys/firmware/efi ] && echo true || echo false)
    if [[ $is_uefi == "true" ]]; then
        grub_type="grub-efi"
        grub_location="/boot/efi"
    else
        grub_type="grub-legacy"
        grub_location="$disk_dev"
    fi
}

ManualDisk() {
    testing="true"
    # TODO: Add manual disk partitioning support
    # 1. Check if UEFI or BIOS
    if [[ $is_uefi == "true" || $testing == "true" ]]; then
        # 2. Show what the user has to create like in arch wiki
        gum style --border normal --margin "1" --padding "1 2" "Example partition layout:"
        gum style --border normal --foreground $warning_color "Note: swap partition needs to be enabled after install"
        echo ""
        echo ""

        EFI_PART=$(gum style --border normal "EFI system partition")
        EFI_SIZE=$(gum style --border normal "At least 300 MiB")
        SWAP_PART=$(gum style --border normal "Linux swap")
        SWAP_SIZE=$(gum style --border normal "More than 512 MiB")
        ROOT_PART=$(gum style --border normal "Linux x86-64 root")
        ROOT_SIZE=$(gum style --border normal "Remainder of the device")
        EFI_ROW=$(gum join "$EFI_PART" "$EFI_SIZE")
        SWAP_ROW=$(gum join "$SWAP_PART" "$SWAP_SIZE")
        ROOT_ROW=$(gum join "$ROOT_PART" "$ROOT_SIZE")

        gum join --vertical "$EFI_ROW" "$SWAP_ROW" "$ROOT_ROW"

        # 3. Open cfdisk
        gum style --border normal --margin "1" --padding "1 2" "Please select the disk to partition" "$(gum style --foreground "$warning_color" 'WARNING: This will erease the whole disk')"
        disk_dev=$(lsblk -pdo name | grep -v zram | grep -v NAME | grep -v loop | grep -v sr | gum choose --limit 1)
        clear
        gum style --border normal --margin "1" --padding "1 2" "Password: crystal"
        sudo cfdisk $disk_dev

        # 4. Ask what partition is what
        clear
        gum style --border normal --margin "1" --padding "1 2" "Select EFI partition"
        efi_part=$(lsblk | grep -v zram | grep -v NAME | grep -v loop | grep -v sr | gum choose --limit 1)
        clear
        gum style --border normal --margin "1" --padding "1 2" "Select EFI partition mountpoint"
        efi_part_mount=$(gum choose --limit 1 "none" "/" "/boot" "/boot/efi" "/home" "/opt" "/tmp" "/usr" "var")
        clear
        gum style --border normal --margin "1" --padding "1 2" "Select root partition"
        root_part=$(lsblk | grep -v zram | grep -v NAME | grep -v loop | grep -v sr | gum choose --limit 1)
        clear
        gum style --border normal --margin "1" --padding "1 2" "Select root partition mountpoint"
        root_part_mount=$(gum choose --limit 1 "none" "/" "/boot" "/boot/efi" "/home" "/opt" "/tmp" "/usr" "var")

        # TODO: remove junk from efi_part, root_part
    else
        echo Manual BIOS partitioning is not supported yet
    fi
}

Desktop() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Select a desktop to use"
    desktop=$(gum choose --limit 1 gnome kde budgie mate cinnamon lxqt sway i3gaps herbstluftwm awesome bspwm)
}

Misc() {
    clear
    gum style --border normal --margin "1" --padding "1 2" "Some miscellaneous settings" "Use space to enable/disable"
    misc_settings=$(gum choose --limit 4 "Enable ipv6" "Enable timeshift" "Enable zramd" "Enable flatpak")
    enable_ipv6="false"
    enable_timeshift="false"
    enable_zramd="false"
    enable_flatpak="false"
    if [[ $misc_settings == *"ipv6"* ]]; then
        enable_ipv6="true"
    fi
    if [[ $misc_settings == *"timeshift"* ]]; then
        enable_timeshift="true"
    fi
    if [[ $misc_settings == *"zramd"* ]]; then
        enable_zramd="true"
    fi
    if [[ $misc_settings == *"flatpak"* ]]; then
        enable_flatpak="true"
    fi
}


Summary() {
    clear
    CONTINUE=false
    gum confirm "$(gum style --border normal --margin '1' --padding '1 2' "Summary, is this correct?" "" "keymap: $keymap" "timezone: $timezone" "locale: $locale" "username: $username" "password: $password" "Default shell: $shell" "root-password: $root_password" "hostname: $hostname" "disk: $disk" "desktop: $desktop" "ipv6: $enable_ipv6" "timeshift: $enable_timeshift" "enable zramd: $enable_zramd" "enable flatpak: $enable_flatpak" "efi: $is_uefi")" && CONTINUE=true
    if [[ $CONTINUE != "true" ]]; then
        Change
    else
        # Remove config.json if it exists
        if [[ $(ls | grep "/tmp/config.json") ]]; then
            rm /tmp/config.json
        fi
        # Make config.json
        echo "{
        \"partition\": {
            \"device\": \"$disk\",
            \"mode\": \"Auto\",
            \"efi\": $is_uefi,
            \"partitions\": []
        },
        \"bootloader\": {
            \"type\": \"$grub_type\",
            \"location\": \"$grub_location\"
        },
        \"locale\": {
            \"locale\": [
                \"$locale\"
            ],
            \"keymap\": \"$keymap\",
            \"timezone\": \"$timezone\"
        },
        \"networking\": {
            \"hostname\": \"$hostname\",
            \"ipv6\": $enable_ipv6
        },
        \"users\": [
            {
                \"name\": \"$username\",
                \"password\": \"$crypt_password\",
                \"hasroot\": true,
                \"shell\": \"$shell\"
            }
        ],
        \"rootpass\": \"$crypt_root_password\",
        \"desktop\": \"$desktop\",
        \"timeshift\": $enable_timeshift,
        \"extra_packages\": [
            $fish_pkg
        ],
        \"flatpak\": $enable_flatpak,
        \"zramd\": $enable_zramd,
        \"unakite\": {
            \"enable\": false,
            \"root\": \"/dev/null\",
            \"oldroot\": \"$disk\",
            \"efidir\": \"/dev/null\",
            \"bootdev\": \"/dev/null\"
        },
        \"kernel\": \"linux\"
    }" > /tmp/config.json
    fi
}

Change() {
    gum style --border normal --margin '1' --padding '1 2' "What do you want to change?"
    $(gum choose --limit 1 Timezone Keymap Locale Username Password RootPassword Shell Hostname AutoDisk Desktop Misc)
    Summary
}

Install() {
    CONTINUE=false
    gum confirm "$(gum style --border normal --margin '1' --padding '1 2' "Are you sure you want to install?" "$(gum style --foreground "$warning_color" 'WARNING: This will erease the whole disk')")" && CONTINUE=true
    if [[ $CONTINUE != "true" ]]; then
        echo "Exiting. Have a good day!"
        exit
    else
        sudo jade config /tmp/config.json
    fi
}

Welcome
Timezone
Keymap
Locale
Username
Password
RootPassword
Shell
Hostname
AutoDisk # TODO: Add manual partitioning support
# ManualDisk
Desktop
Misc
UEFICheck
Summary
Install
