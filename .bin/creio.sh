#!/usr/bin/env bash

### === VARIABLES ===
# linux | linux-lts | linux-zen
KERNEL="linux-zen"
KERNEL_PARAMS="loglevel=3 nowatchdog nmi_watchdog=0"
# btrfs | ext4
FS_TYPE="btrfs"
# systemd-boot | grub-efi | grub
BOOT_LOADER="grub-efi"
HOST_NAME="box"
THREADS=$(nproc)


# === PKGS LIST ===
PKGS=(
base base-devel linux-firmware nano reflector openssh haveged
os-prober
networkmanager ufw wireless-regdb wireless_tools iwd
wget git rsync openbsd-netcat pv bash-completion less bat btop
zip unzip unrar 7zip gzip bzip2 zlib hdparm nvme-cli smartmontools
xf86-input-libinput
pipewire pipewire-audio pipewire-pulse lib32-pipewire pipewire-alsa pipewire-jack
gst-plugin-pipewire wireplumber
zram-generator cpupower ananicy-cpp
zsh starship zsh-autosuggestions zsh-syntax-highlighting zsh-fast-syntax-highlighting oh-my-zsh-git
fastfetch inxi tmux micro
ttf-jetbrains-mono-nerd
snapper timeshift
# sddm
# firefox firefox-i18n-ru firefox-ublock-origin telegram-desktop
)


## === HELPERS ===
BLUE='\033[0;34m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

LOG_FILE="/tmp/install.log"
rm -rf "$LOG_FILE"

# Функция для простых текстовых логов
log() {
  echo ""
  echo -e "${BLUE}[$(date +%T)] [INFO]${NC} $*" | tee -a "$LOG_FILE"
}
# Функция для логирования обычных команд
run() {
  echo -e "${GREEN}[$(date +%T)] Executing:${NC} $*" >> "$LOG_FILE"
  eval "$@" 2>&1 | tee -a "$LOG_FILE"
}
success() { echo -e "${GREEN}󰋼 [SUCCESS]${NC} $*" | tee -a "$LOG_FILE"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $*" | tee -a "$LOG_FILE"; }
error() { echo -e "${RED}󰋼 [ERROR]${NC} $*" | tee -a "$LOG_FILE"; }
die() { error "$*"; exit 1; }

_check_root() { [[ $EUID -eq 0 ]] || die "Run as root || sudo"; }
_check_root

log "CHECKING INTERNET..."
if ! ping -c 1 8.8.8.8 &>/dev/null; then
   die "ERROR: Internet required."
fi

# --- CLEANUP /mnt ---
umount -Rl /mnt &>/dev/null
sync


## === MIRRORS ===
rm -rf /etc/pacman.d/hooks/*
log "UPDATING MIRRORLIST..."
run 'pacman -Syy --noconfirm archlinux-keyring' >/dev/null
run 'pacman -S --noconfirm --needed reflector gum' >/dev/null
# ПЕРЕХЕШИРУЕМ ПУТИ, чтобы Bash увидел gum
hash -r
gum spin --spinner dot --title "sort mirrorlist..." -- bash -c "
  run 'reflector -p https,http --sort rate -l 20 -f 10 --threads 5 --save /etc/pacman.d/mirrorlist' >/dev/null
  run 'pacman -Syy --noconfirm' >/dev/null
"


# ------------- FUNCTIONS DONT CHROOT -----------------

## === CREATE USER ===
_create_user() {
  log "CREATE USER..."
  # Цикл для USERNAME: не выпустит, пока не введешь имя
  while true; do
    USERNAME=$(gum input --placeholder "Username" --header "Enter user login")
    if [[ -n "$USERNAME" ]]; then
      log "User set to: $USERNAME"
      break
    else
      warn "Username cannot be empty!"
      sleep 1
    fi
  done

  while true; do
    PASSWORD=$(gum input --password --placeholder "Password" --header "Set a password (Root/User)")
    C_PASSWORD=$(gum input --password --placeholder "Repeat password" --header "Password confirmation")

    if [[ -n "$PASSWORD" && "$PASSWORD" == "$C_PASSWORD" ]]; then
      success "Passwords for $USERNAME are set"
      break
    else
      warn "Passwords don't match or are empty! Try again."
      sleep 1
    fi
  done
}


## === DETECTING HARDWARE ===
_detecting_hardware() {
  log "DETECTING HARDWARE..."

  ## === DRIVE SELECTION ===
  [[ -z "$TARGET_DRIVE" ]] && TARGET_DRIVE=$(lsblk -dpno NAME,SIZE | gum choose --header "Select Drive" | awk '{print $1}')
  [[ -z "$TARGET_DRIVE" ]] && die "DRIVE: nothing selected"
  if [[ $TARGET_DRIVE =~ [0-9]$ ]]; then P="p"; else P=""; fi
  BOOT_PART="${TARGET_DRIVE}${P}1"
  ROOT_PART="${TARGET_DRIVE}${P}2"

  ## === FS_TYPE ===
  IS_EFI=false
  [[ -d "/sys/firmware/efi" ]] && IS_EFI=true
  if [[ -z "$FS_TYPE" ]]; then
    FS_TYPE=$(gum choose --header "Выберите файловую систему (Enter для подтверждения)" \
    "btrfs" \
    "ext4")
  fi

  case $FS_TYPE in
  "btrfs")
    log "FS_TYPE: btrfs"
    ;;
  "ext4")
    log "FS_TYPE: ext4"
    ;;
  *)
    log "FS_TYPE: default btrfs"
    FS_TYPE="btrfs"
    ;;
  esac

  [[ "$FS_TYPE" == "btrfs" ]] && PKGS+=(btrfs-progs)

  # === BOOT_LOADER SELECTION ===
  if [[ -z "$BOOT_LOADER" ]]; then
    # Если это не EFI, то выбор сужается только до GRUB
    if [[ "$IS_EFI" == "false" ]]; then
      warn "Legacy BIOS detected, force GRUB selection"
      BOOT_LOADER="grub"
    else
      BOOT_LOADER=$(gum choose --header "Select bootloader" "systemd-boot" "grub-efi")
    fi
  fi

  case $BOOT_LOADER in
  "systemd-boot")
    log "BOOT_LOADER: systemd-boot"
    PKGS+=(efibootmgr) # Для systemd-boot всегда нужен efibootmgr
    ;;
  "grub-efi")
    log "BOOT_LOADER: grub-efi"
    PKGS+=(efibootmgr grub)
    # Добавляем плюшки для Btrfs, если выбрана эта ФС
    [[ "$FS_TYPE" == "btrfs" ]] && PKGS+=(grub-btrfs inotify-tools)
    ;;
  "grub")
    log "BOOT_LOADER: grub (Legacy)"
    PKGS+=(grub)
    ;;
  *)
    # Обработка Esc
    if [[ "$IS_EFI" == "true" ]]; then
      BOOT_LOADER="systemd-boot"
      PKGS+=(efibootmgr)
    else
      BOOT_LOADER="grub"
      PKGS+=(grub)
    fi
    log "BOOT_LOADER: default to $BOOT_LOADER"
    ;;
  esac

  if [[ -z "$HOST_NAME" ]]; then
    HOST_NAME=""
    while [[ -z "$HOST_NAME" ]]; do
      HOST_NAME=$(gum input --placeholder "Hostname" --header "Enter hostname" --header.foreground="141")
    done
  fi

  CPU_VENDOR=$(grep -m 1 'vendor_id' /proc/cpuinfo | awk '{print $3}')
  # Детект CPU (Микрокод)
  [[ "$CPU_VENDOR" == "AuthenticAMD" ]] && CPU_UCODE="amd-ucode" && PKGS+=(amd-ucode)
  [[ "$CPU_VENDOR" == "GenuineIntel" ]] && CPU_UCODE="intel-ucode" && PKGS+=(intel-ucode)
  CPU_MODEL=$(grep -m 1 'model name' /proc/cpuinfo | cut -d: -f2 | sed 's/^ //')
  GPU_LIST=$(lspci | grep -E "VGA|3D" | tr '[:upper:]' '[:lower:]')
  GPU_MODEL=$(lspci | grep -E "VGA|3D" | cut -d: -f3 | sed 's/^ //')
  VIRT=$(systemd-detect-virt)
  [[ "$VIRT" == "none" ]] && VIRT_NO="Железо (Bare Metal)" || VIRT_NO="Виртуализация ($VIRT)"
  TIME_ZONE=$(curl -s --connect-timeout 5 https://ipinfo.io/timezone)
  if [[ -z "$TIME_ZONE" || "$TIME_ZONE" == *"{"* ]]; then
    warn "Automatic zone detection failed (API error). Select manually...."
    TIME_ZONE=$(timedatectl list-timezones | gum filter --placeholder "Start writing (e.g. Moscow)..." --header "Select your region")
  fi
  [[ -z "$TIME_ZONE" ]] && TIME_ZONE="UTC"
}


## === LINUX KERNEL ===
_pkgs_kernel() {
  log "Configuring kernel versions..."

  if [[ ! "$KERNEL" =~ ^(linux|linux-lts|linux-zen)$ ]]; then
    log "Kernel select..."
    # Сохраняем выбор в промежуточную переменную
    KERNEL=$(gum choose --header "Select kernel (Enter to submit)" \
    "linux-zen" \
    "linux-lts" \
    "linux (standard)")
  fi

  case "$KERNEL" in
  *"linux-zen"*)
    KERNEL="linux-zen"
    PKGS+=(linux-zen linux-zen-headers)
    ;;
  *"linux-lts"*)
    KERNEL="linux-lts"
    PKGS+=(linux-lts linux-lts-headers)
    ;;
  *)
    # Сюда попадет и "linux (standard)", и любой Esc
    KERNEL="linux"
    PKGS+=(linux linux-headers)
    ;;
  esac
  log "Kernel selected: $KERNEL"
}


## === GPU ===
_pkgs_gpu_drivers() {
  log "Detecting hardware and virtualization..."
  run "lspci -k | grep -A 2 -E '(VGA|3D)'"

  # Графический фундамент (X-сервер и прослойки)
  PKGS+=(xorg-server xorg-xinit xorg-xkill xorg-xrdb xorg-xinput xorg-xwayland)

  # Базовые библиотеки API (Mesa + Vulkan + OpenCL Loader)
  PKGS+=(mesa lib32-mesa vulkan-mesa-layers vulkan-icd-loader lib32-vulkan-icd-loader)
  PKGS+=(ocl-icd lib32-ocl-icd opencl-headers xf86-video-fbdev)

  # Проверка на NVIDIA
  if echo "$GPU_LIST" | grep -q "nvidia"; then
    log "Selecting a graphics driver NVIDIA..."
    GPU_TYPE=$(gum choose --header "Какую видеокарту используем?" "NVIDIA Modern (RTX/GTX 16xx) nvidia-open" "NVIDIA Legacy (Maxwell/Kepler/etc...)" "AMD/Intel (Mesa)" "VMware/VBox")

    case "$GPU_TYPE" in
    "NVIDIA Modern (RTX/GTX 16xx) nvidia-open")
      log "GPU: NVIDIA Modern"
      PKGS+=(nvidia-open-dkms nvidia-utils lib32-nvidia-utils egl-wayland nvidia-prime nvtop opencl-nvidia lib32-opencl-nvidia)
      ;;
    "NVIDIA Legacy (Maxwell/Kepler/etc...)")
      log "GPU: NVIDIA Legacy"
      PKGS+=(xf86-video-nouveau)
      warn "After installing the system, do not forget to install the legacy driver from the AUR (for example, nvidia-470xx-dkms) https://wiki.archlinux.org/title/NVIDIA"
      ;;
    "AMD/Intel (Mesa)")
      log "GPU: AMD/Intel"
      PKGS+=()
      ;;
    "VMware/VBox")
      log "GPU: VMware/VBox"
      PKGS+=()
      ;;
    *)
      log "GPU: xf86-video-nouveau"
      PKGS+=(xf86-video-nouveau)
      ;;
    esac
  fi

  # Проверка на AMD (встройка или дискретка)
  if echo "$GPU_LIST" | grep -q "amd"; then
    log "GPU: AMD detected"
    # Универсальный стек AMD (графика + вулкан + 32бит)
    PKGS+=(xf86-video-amdgpu vulkan-radeon lib32-vulkan-radeon amdgpu_top)
    # Свободный стек OpenCL для AMD
    PKGS+=(rocm-opencl-runtime)
  fi

  # Проверка на Intel
  if echo "$GPU_LIST" | grep -q "intel"; then
    log "GPU: Intel detected"
    # Универсальный стек Intel (Vulkan + 32-bit + Загрузчик)
    # Для Intel пакет xf86-video-intel обычно НЕ нужен
    PKGS+=(vulkan-intel lib32-vulkan-intel intel-media-driver libva-intel-driver)
    # Стек OpenCL для Intel
    PKGS+=(intel-compute-runtime)
  fi

  # Детект Виртуализации
  if [[ "$VIRT" != "none" ]]; then
    log "Virtual environment detected: $VIRT"
    case $VIRT in
    oracle|vbox|container-other)
      log "Installing VirtualBox guest tools..."
      PKGS+=(virtualbox-guest-utils)
      ;;
    vmware)
      log "Installing VMware guest tools..."
      # xf86-video-vmware теперь в AUR, полагаемся на modesetting + mesa
      # Он подхватится автоматически, если есть xorg-server и mesa
      PKGS+=(open-vm-tools xf86-input-vmmouse)
      ;;
    kvm|qemu)
      log "Installing QEMU/KVM guest tools..."
      PKGS+=(qemu-guest-agent spice-vdagent xf86-video-qxl)
      ;;
    esac
    # Фолбэк для всех
    PKGS+=(xf86-video-vesa)
  fi
}


## === VALIDATE PKGS ===
_validate_pkgs() {
  log "VALIDATE PACKAGES..."
  VALID_PKGS=()
  for pkg in "${PKGS[@]}"; do
    if pacman -Si "$pkg" >/dev/null 2>&1; then
      VALID_PKGS+=("$pkg")
    else
      warn "Warning: Package $pkg not found, skipping..."
    fi
  done
  log "INSTALLING PACKAGES: ${VALID_PKGS[*]}"
}


## === SYSTEM SUMMARY ===
_system_summary() {
  gum style --border normal --margin "1 0" --padding "1 2" \
  --border-foreground 212 \
  "SYSTEM SUMMARY:" \
  "CPU:           $CPU_MODEL" \
  "GPU:           $GPU_MODEL" \
  "Platform:      $VIRT_NO" \
  "Hostname:      $HOST_NAME" \
  "Zone:          $TIME_ZONE" \
  "FS TYPE:       $FS_TYPE" \
  "Boot Mode:     $([[ "$IS_EFI" == "true" ]] && echo "UEFI" || echo "BIOS")" \
  "BOOT LOADER:   $BOOT_LOADER" \
  "Kernel:        $KERNEL" >&2

  # Дублируем в лог
  {
    echo "--- System Summary ---"
    echo "CPU:           $CPU_MODEL"
    echo "GPU Found:     $GPU_MODEL"
    echo "Platform:      $VIRT_NO"
    echo "Timezone:      $TIME_ZONE"
    echo "FS TYPE:       $FS_TYPE"
    echo "BOOT LOADER:   $BOOT_LOADER"
    echo "Kernel:        $KERNEL"
    echo "----------------------"
  } >> "$LOG_FILE"
}


## === PREPARE TARGET_DRIVE ===
_format_mount() {
  log "Wiping disk header..."
  dd if=/dev/zero of="$TARGET_DRIVE" bs=1M count=100 conv=fdatasync status=progress

  # === PARTITIONING ===
  log "Creating partitions..."
  if [[ "$IS_EFI" == "true" ]]; then
    log "Mode: UEFI (GPT)"
    parted -s "$TARGET_DRIVE" -- \
    mklabel gpt \
    mkpart primary fat32 1MiB 513MiB \
    set 1 esp on \
    mkpart primary 513MiB 100%

    BOOT_PART="${TARGET_DRIVE}${P}1"
    ROOT_PART="${TARGET_DRIVE}${P}2"
  else
    log "Mode: Legacy BIOS (GPT + bios_grub)"
    # На GPT для Legacy GRUB нужен специальный раздел bios_grub
    parted -s "$TARGET_DRIVE" -- \
    mklabel gpt \
    mkpart primary 1MiB 2MiB \
    set 1 bios_grub on \
    mkpart primary fat32 2MiB 513MiB \
    mkpart primary 513MiB 100%

    # Сдвигаем индексы: 1-bios_grub, 2-boot, 3-root
    BOOT_PART="${TARGET_DRIVE}${P}2"
    ROOT_PART="${TARGET_DRIVE}${P}3"
  fi
  sync && sleep 2

  # === FORMAT & MOUNT ===
  log "FORMAT & MOUNT ($FS_TYPE)..."
  wipefs -af "$ROOT_PART"
  wipefs -af "$BOOT_PART"

  if [[ "$FS_TYPE" == "btrfs" ]]; then
    mkfs.btrfs -f -L ROOT "$ROOT_PART"
    yes | mkfs.fat -F32 -n "BOOT" "$BOOT_PART"
    mount "$ROOT_PART" /mnt
    btrfs subvolume create /mnt/{@,@home,@cache,@log,@snapshots}
    umount /mnt

    BTRFS_OPTS="compress=zstd:1,discard=async,noatime"
    mount -o "$BTRFS_OPTS,subvol=@" "$ROOT_PART" /mnt
    mkdir -p /mnt/{boot,home,var/cache,var/log,.snapshots}
    mount -o "$BTRFS_OPTS,subvol=@home" "$ROOT_PART" /mnt/home
    mount -o "$BTRFS_OPTS,subvol=@cache" "$ROOT_PART" /mnt/var/cache
    mount -o "$BTRFS_OPTS,subvol=@log" "$ROOT_PART" /mnt/var/log
    # rm noatime, default relatime
    mount -o "${BTRFS_OPTS//noatime/},subvol=@snapshots" "$ROOT_PART" /mnt/.snapshots
    [[ "$BOOT_LOADER" == "systemd-boot" ]] && SYSTEMD_FLAGS="rootflags=subvol=/@ rootfstype=btrfs" || SYSTEMD_FLAGS=""
    if [[ "$BOOT_LOADER" == "systemd-boot" ]]; then
      # Стандарт для systemd-boot и обычного GRUB
      log "Configuring mount (/boot)"
      mkdir -p /mnt/boot
      mount -t vfat "$BOOT_PART" /mnt/boot
    elif [[ "$BOOT_LOADER" == "grub-efi" ]]; then
      # Для GRUB efi монтируем в /boot/efi
      log "Configuring mount for GRUB (/boot/efi)"
      mkdir -p /mnt/boot/efi
      mount -t vfat "$BOOT_PART" /mnt/boot/efi
    else
      # Для GRUB монтируем в /boot
      log "Configuring mount for GRUB (/boot)"
      mkdir -p /mnt/boot
      mount -t vfat "$BOOT_PART" /mnt/boot
    fi

  elif [[ "$FS_TYPE" == "ext4" ]]; then
    log "Formatting ext4..."
    yes | mkfs.ext4 -F -L ROOT "$ROOT_PART"
    yes | mkfs.fat -F32 -n "BOOT" "$BOOT_PART"
    log "Mounting partitions..."
    mount "$ROOT_PART" /mnt || die "Failed to mount root partition"
    mkdir -p /mnt/boot
    # Монтируем и проверяем результат
    if ! mount -t vfat "$BOOT_PART" /mnt/boot; then
      error "Failed to mount /boot partition!"
      # Попробуем создать заново, если папка занята
      umount -l /mnt/boot 2>/dev/null
      mount -t vfat "$BOOT_PART" /mnt/boot || die "Critical error: cannot mount boot"
    fi
    SYSTEMD_FLAGS=""
  else
    die "Unsupported FS_TYPE: $FS_TYPE"
  fi

  ROOT_UUID=$(lsblk -no UUID "$ROOT_PART")
  success "Drive: $TARGET_DRIVE | ROOT UUID: $ROOT_UUID"
}


# ------------- LOGIC DONT CHROOT -----------------
_create_user
_detecting_hardware
_pkgs_kernel
_pkgs_gpu_drivers
_validate_pkgs
_system_summary

warn "ВНИМАНИЕ: это приведет к форматированию диска $TARGET_DRIVE. Продолжать?\n"
gum confirm "WARNING: This will wipe $TARGET_DRIVE. Continue?" || exit 1

_format_mount


# ------------- FUNCTIONS CHROOT -----------------

## === PACSTRAP BASE ===
_install_base_system() {
  log "PACSTRAP BASE..."
  echo -e "\n"
  gum spin --spinner meter --title "Installing packages to /mnt..." -- bash -c "
  echo '--- START PACSTRAP ---' >> $LOG_FILE
  pacstrap /mnt ${VALID_PKGS[*]} >> $LOG_FILE 2>&1
  echo '--- END PACSTRAP ---' >> $LOG_FILE
  "
  # Проверка кода возврата (после gum spin $? относится к команде внутри bash -c)
  if [[ $? -eq 0 ]]; then
    success "install base system"
  else
    die "base system, log: $LOG_FILE"
  fi

  log "GENERATING FSTAB..."
  if genfstab -U /mnt > /mnt/etc/fstab; then
    success "FSTAB generate (UUID)"
    ## Фикс безопасности для /boot (bootctl)
    sed -i 's/fmask=0022,dmask=0022/fmask=0077,dmask=0077/g' /mnt/etc/fstab
  else
    die "no generate FSTAB"
  fi
}


## === SYSTEM SETTINGS ===
_system_settings() {
  log "Entering system chroot settings..."
  run arch-chroot /mnt /bin/bash <<EOT
  # HOSTNAME & HOSTS
  echo "$HOST_NAME" > /etc/hostname
  cat <<EOF >/etc/hosts
127.0.0.1       localhost
::1             localhost
127.0.1.1       $HOST_NAME.localdomain $HOST_NAME
EOF

  # locale
  ln -sf /usr/share/zoneinfo/$TIME_ZONE /etc/localtime
  hwclock --systohc --utc

  echo -e "en_US.UTF-8 UTF-8\nru_RU.UTF-8 UTF-8" >> /etc/locale.gen
  locale-gen
  echo "LANG=ru_RU.UTF-8" > /etc/locale.conf
  echo -e "KEYMAP=ru\nFONT=cyr-sun16" > /etc/vconsole.conf

  # pacman
  sed -i -e 's/^#ParallelDownloads = 5/ParallelDownloads = 10/' \
    -e '/Color/s/^#//' -e '/VerbosePkgLists/s/^#//' \
    -e '/\[multilib\]/,/Include/s/^#//' /etc/pacman.conf
  pacman -S --noconfirm --needed haveged
  haveged -w 1024
  pacman-key --init && pacman-key --populate
  pkill haveged
  pacman -Syy --noconfirm

  # makepkg optimization
  sed -i -e "s/#MAKEFLAGS=.*/MAKEFLAGS=\"-j$THREADS\"/" \
    -e 's/CFLAGS="-march=x86-64/CFLAGS="-march=native/' \
    -e "s/COMPRESSZST=.*/COMPRESSZST=(zstd -c -T0 - --threads=0)/" \
    -e 's/\([^!]\)debug\b/\1!debug/' /etc/makepkg.conf

  # create user
  echo "root:$PASSWORD" | chpasswd
  useradd -m -g users -G "audio,video,input,adm,disk,log,network,scanner,storage,power,wheel" -s /usr/bin/zsh "$USERNAME"
  echo "$USERNAME:$PASSWORD" | chpasswd
  echo "%wheel ALL=(ALL) ALL" >> /etc/sudoers

  # create media
  mkdir -p /media/games
  chmod 755 -R /media
  chown -R "$USERNAME":users /media

  # vbox
  if [[ "$VIRT" == "oracle" || "$VIRT" == "vbox" || "$VIRT" == "container-other" ]]; then
    pacman -S --noconfirm --needed virtualbox-guest-utils
    systemctl enable vboxservice
    usermod -a -G vboxsf "$USERNAME"
  fi
  # Фикс NVIDIA в виртуалке (чтобы не было nvidia_uvm error)
  if [[ "$VIRT" != "none" ]]; then
    ln -sf /dev/null /etc/modules-load.d/nvidia-utils.conf
  fi

  # SYSTEMD NETWORK
  mkdir -p /etc/systemd/network
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

  # NETWORKMANAGER
  mkdir -p /etc/NetworkManager/conf.d
  cat <<EOF >/etc/NetworkManager/conf.d/99-connection.conf
[device]
wifi.scan-rand-mac-address=no
# wifi.backend=iwd
[main]
dhcp=internal
# dhcp=dhclient
# dhcp=dhcpcd
# dns=systemd-resolved
# dns=dnsmasq
[connection]
# ipv6.method=ignore
[wifi]
powersave=2
EOF

EOT

  if [[ $? -eq 0 ]]; then
    success "Settings systems chroot done"
  else
    error "Settings systems chroot"
  fi
}


## === SYSTEM OPTIMIZATION ===
_system_optimization() {
    log "Application of universal optimizations..."

    run arch-chroot /mnt /bin/bash <<EOF
    ## Лимиты (Важно для стабильности игр и тяжелого софта)
    mkdir -p /etc/security/limits.d
    cat <<EOT > /etc/security/limits.d/99-limits.conf
* soft nofile 524288
* hard nofile 524288
@audio - rtprio 99
@audio - memlock unlimited
EOT

    # 2. SYSCTL (Безопасный тюнинг памяти и сети)
    # Убираем экстремальный swappiness, ставим средний баланс
    cat <<EOT > /etc/sysctl.d/99-performance.conf
### --- MEMORY OPTIMIZATION (ZRAM) ---
# Агрессивно используем ZRAM (стандарт для zram-generator)
vm.swappiness = 100
# Снижаем давление на кэш ФС (ускоряет отзывчивость интерфейса и поиск файлов)
vm.vfs_cache_pressure = 50
## или Баланс между оперативой и свопом
# vm.swappiness = 60
# vm.vfs_cache_pressure = 100
## Улучшение отзывчивости при записи больших файлов
vm.dirty_ratio = 20
vm.dirty_background_ratio = 10
## BBR - стандарт Google(нужен для низкого пинга и высокой скорости)
net.core.default_qdisc = fq
net.ipv4.tcp_congestion_control = bbr
net.ipv4.tcp_fastopen = 3
EOT

    ## ZRAM
    # Ставим 50% от RAM — это безопасно для любого объема памяти
    cat <<EOT > /etc/systemd/zram-generator.conf
[zram0]
zram-size = ram / 2
compression-algorithm = zstd
swap-priority = 100
fs-type = swap
EOT

    ## Планировщики дисков
    # Этот конфиг сам поймет, где SSD, а где HDD, и применит нужное
    mkdir -p /etc/udev/rules.d
    cat <<EOT > /etc/udev/rules.d/60-ioschedulers.rules
# HDD bfq хорош для отзывчивости
ACTION=="add|change", KERNEL=="sd[a-z]*", ATTR{queue/rotational}=="1", ATTR{queue/scheduler}="bfq"
# ssd, bfq || mq-deadline || kyber
ACTION=="add|change", KERNEL=="sd[a-z]*|mmcblk[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
# nvme, mq-deadline || none
ACTION=="add|change", KERNEL=="nvme[0-9]*", ATTR{queue/rotational}=="0", ATTR{queue/scheduler}="mq-deadline"
EOT

    ## Таймеры (Для нормальной работы звука)
    cat <<EOT > /etc/udev/rules.d/40-timer-permissions.rules
KERNEL=="rtc0", GROUP="audio"
KERNEL=="hpet", GROUP="audio"
EOT

    ## SYSTEMD (Таймауты и логи)
    # Стандартные таймауты Arch слишком долгие (90с), 15с — оптимально для всех
    mkdir -p /etc/systemd/system.conf.d
    cat <<EOT > /etc/systemd/system.conf.d/90-timeout.conf
[Manager]
DefaultTimeoutStartSec=15s
DefaultTimeoutStopSec=15s
EOT

    mkdir -p /etc/systemd/journald.conf.d
    cat <<EOT > /etc/systemd/journald.conf.d/90-storage.conf
[Journal]
Storage=auto
SystemMaxUse=64M
EOT
EOF
}


## === ZSH & AUR HELPER (yay) ===
_setup_user_shell() {
  log "Configure ($USERNAME)..."
  run arch-chroot /mnt /bin/bash <<EOF
    echo ">>> Install yay..."
    cd /home/$USERNAME
    sudo -u "$USERNAME" git clone https://aur.archlinux.org/yay-bin.git
    cd yay-bin
    sudo -u "$USERNAME" makepkg -sr --noconfirm
    pacman -U --noconfirm --needed \$(ls *.pkg.tar.zst | grep -v "debug")
    cd /home/$USERNAME
    rm -rf yay-bin

    echo ">>> Create .zshrc $USERNAME..."

    cat <<'ZSHRC' > /home/$USERNAME/.zshrc
#!/usr/bin/zsh

# [[ -z \$DISPLAY && \$XDG_VTNR -eq 1 ]] && exec startx &> /dev/null

export PATH=\$HOME/.bin:\$HOME/.local/bin:\$PATH
export HISTFILE=~/.zhistory HISTSIZE=3000 SAVEHIST=3000
autoload -Uz compinit; for dump in ~/.zcompdump(N.mh+24); do compinit; done; compinit -C

[[ -e /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh ]] && source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh
[[ -e /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh ]] && source /usr/share/zsh/plugins/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh
[[ -e /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh ]] && source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh

if [[ -d /usr/share/oh-my-zsh ]]; then
  export ZSH="/usr/share/oh-my-zsh"
  ZSH_THEME="af-magic"
  DISABLE_AUTO_UPDATE="true"
  plugins=()
  ZSH_CACHE_DIR=\$HOME/.cache/oh-my-zsh
  mkdir -p \$ZSH_CACHE_DIR
  [[ -e \$ZSH/oh-my-zsh.sh ]] && source \$ZSH/oh-my-zsh.sh
else
  command -v starship >/dev/null && eval "\$(starship init zsh)"
fi
ZSHRC

    chown -R "$USERNAME":users /home/$USERNAME
EOF

  if [[ $? -eq 0 ]]; then
    success "The user environment is configured"
  else
    error "Error configuring user environment"
  fi
}


## === SETUP BOOTLOADER ===
_setup_bootloader() {
  log "settings ($BOOT_LOADER)..."

  UCODE_LINE=""
  [[ -f "/mnt/boot/${CPU_UCODE}.img" ]] && UCODE_LINE="initrd /${CPU_UCODE}.img"

  run arch-chroot /mnt /bin/bash <<EOF
    echo ">>> generate initramfs..."
    if ! mkinitcpio -P; then
      echo ">>> ERROR build initramfs"
      exit 1
    fi

    if [[ "$BOOT_LOADER" == "grub-efi" ]]; then
      echo ">>> install GRUB (EFI)..."
      grub-install --target=x86_64-efi --efi-directory=/boot/efi --bootloader-id=GRUB --recheck

      sed -i "s|^GRUB_CMDLINE_LINUX_DEFAULT=.*|GRUB_CMDLINE_LINUX_DEFAULT=\"$KERNEL_PARAMS\"|" /etc/default/grub
      sed -i '/#GRUB_DISABLE_OS_PROBER/s/^#//' /etc/default/grub

      grub-mkconfig -o /boot/grub/grub.cfg
    elif [[ "$BOOT_LOADER" == "grub" ]]; then
      echo ">>> install GRUB (Legacy/BIOS) $TARGET_DRIVE..."
      grub-install --target=i386-pc "$TARGET_DRIVE" --recheck
      grub-mkconfig -o /boot/grub/grub.cfg
    else
      echo ">>> install $BOOT_LOADER..."
      bootctl install

      cat <<EOT > /boot/loader/loader.conf
default arch-${KERNEL}.conf
timeout 3
editor 1
console-mode max
EOT

      # dynamic kernel (linux, linux-zen, linux-lts)
      cat <<EOT > /boot/loader/entries/arch-${KERNEL}.conf
title Arch Linux (${KERNEL})
linux /vmlinuz-${KERNEL}
${UCODE_LINE}
initrd /initramfs-${KERNEL}.img
options root=UUID=${ROOT_UUID} ${SYSTEMD_FLAGS} rw ${KERNEL_PARAMS}
EOT
    fi
EOF

  [[ $? -eq 0 ]] && success "install $BOOT_LOADER" || die "install botloader failed"
}


## === SYSTEMD SERVICES ===
_systemd_services() {
  log "ENABLE SYSTEM SERVICES..."
  run arch-chroot /mnt /bin/bash <<EOF
    if pacman -Qq openssh > /dev/null 2>&1; then
      systemctl enable sshd
    fi
    if pacman -Qq ananicy-cpp > /dev/null 2>&1; then
      systemctl enable ananicy-cpp
    fi
    ## To have GRUB automatically detect Timeshift/Snapper snapshots
    if pacman -Qq grub-btrfs > /dev/null 2>&1; then
      systemctl enable grub-btrfsd
    fi
    if pacman -Qq sddm > /dev/null 2>&1; then
      systemctl enable sddm
    fi

    # systemctl enable plasmalogin
    systemctl enable NetworkManager
EOF
}


# ------------- LOGIC CHROOT -----------------
_install_base_system
_system_settings
_system_optimization
_setup_user_shell
_setup_bootloader
_systemd_services



# === ПОДКЛЮЧЕНИЕ ВНЕШНИХ МОДУЛЕЙ ===
if [ -d "./scripts.d" ]; then
  log "RUNNING ADDITIONAL MODULES..."
  for script in ./scripts.d/*.sh; do
    log "Executing: \$script"
    bash "\$script"
  done
fi


# ------------- FINISH -----------------
_unmount_all() {
  log "Unmounting all partitions..."
  sync # Сбрасываем кэш на диск
  umount -Rl /mnt 2>/dev/null || warn "Some partitions are busy"
}

# Финальное меню после завершения установки
success "Installation finished!"

FINAL_ACTION=$(gum choose --header "What would you like to do next?" \
  "Unmount and Reboot" \
  "Unmount and Exit" \
  "Chroot into system (check everything)" \
  "Just Exit (keep mounted)")

case "$FINAL_ACTION" in
  "Unmount and Reboot")
    _unmount_all
    log "Rebooting in 3 seconds..."
    sleep 3
    reboot
    ;;
  "Unmount and Exit")
    _unmount_all
    success "System unmounted. You can reboot manually."
    exit 0
    ;;
  "Chroot into system (check everything)")
    log "Entering chroot... Type 'exit' to return and finish."
    arch-chroot /mnt /bin/bash
    cat <<EOF
#################################################################
#                   INSTALLATION FINISHED!                      #
#################################################################

  To complete the process, run these commands:

  1. Check logs (if needed):
     cat /tmp/install.log

  2. Unmount system:
     sudo umount -Rl /mnt

  3. Final reboot:
     sudo reboot

#################################################################
EOF
    success "Thanks for using this installer! See you in Arch Linux."
    exit 0
    ;;
  "Just Exit (keep mounted)")
    success "Exiting. /mnt is still mounted."
    exit 0
    ;;
esac