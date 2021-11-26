#!/bin/bash

# echo "${USER} ALL=(root) NOPASSWD:/usr/bin/veracrypt" | sudo tee -a /etc/sudoers

# chmod 700 ~/.env
[[ -s ~/.env ]] && . ~/.env

### --encryption=aes  &&  --filesystem=ext4   &&   -p pass_word
# veracrypt --text --create --filesystem=ext4 /media/Ventoy/backup
# veracrypt --text --create -k "" --pim=0 --encryption=AES-Twofish-Serpent --hash=sha-512 --random-source=/dev/urandom --volume-type=normal --filesystem=fat --size=25M /media/Ventoy/backup
# veracrypt --text --create -k "" --pim=0 --encryption=AES-Twofish-Serpent --hash=sha-512 --random-source=/dev/urandom --volume-type=hidden --filesystem=fat --size=20M /media/Ventoy/backup
# veracrypt --text --mount --pim 0 --keyfiles "" --protect-hidden no

VERACRYPT_MNT="$HOME/mnt/vera"
# VERACRYPT_PASS='zi2eRGSegs$TA6'

if [[ ! $(command -v veracrypt) || ! $(command -v rsync) ]]; then
  echo "yay -S veracrypt rsync" && exit
fi

[[ ! -d $VERACRYPT_MNT ]] && mkdir -p "$VERACRYPT_MNT"
# sudo chown -R ${USER}:users "$VERACRYPT_MNT"

if [[ -e $VERACRYPT_VOLUME ]]; then
  if ! mountpoint -q "$VERACRYPT_MNT"; then
    veracrypt --text --mount --pim 0 --keyfiles "" --protect-hidden no --password="$VERACRYPT_PASS" "$VERACRYPT_VOLUME" "$VERACRYPT_MNT"
  else
    echo "skip mount"
  fi
else
  echo "No mount" && exit
fi
# sudo fatlabel /dev/dm-2 vera
# sudo e2label /dev/dm-2 vera

files=(
"$HOME/.env"
"$HOME/.env_borg"
"$HOME/.2fa"
"$HOME/.ssh"
)

mkdir -p /tmp/vera
# /bin/bash -c "rm -rf /tmp/vera/{.*,*}"
for i in "${files[@]}"; do
  cp -pra $i /tmp/vera
done
[[ ! -d $VERACRYPT_MNT/sync ]] && mkdir "$VERACRYPT_MNT"/sync
rsync -caAXuq --delete --delete-excluded --exclude={"Test/*",".File*"} \
  /tmp/vera/ $VERACRYPT_MNT/sync
echo "Rsync Done!"
rm -rf /tmp/vera

if read -re -p "Umount veracrypt wrap? [y/N]: " ans && [[ $ans == 'y' || $ans == 'Y' ]]; then
  veracrypt -t -d "$VERACRYPT_VOLUME"
fi

ventoy_sync() {
  VENTOY_DISK=/dev/$(lsblk -rno "name,label" | grep Ventoy | awk '{print $1}')
  if [[ $(lsblk -fp | grep Ventoy) ]]; then
    if ! mountpoint -q /media/Ventoy; then
      echo "mount usb Ventoy, cp to usb Done VERACRYPT_VOLUME"
      udisksctl mount -b $VENTOY_DISK > /dev/null
      cp -r $VERACRYPT_VOLUME /media/Ventoy
      udisksctl unmount -b $VENTOY_DISK > /dev/null
      echo "umount usb Ventoy"
    else
      echo "skip mount usb, cp to usb Done VERACRYPT_VOLUME"
      cp -r $VERACRYPT_VOLUME /media/Ventoy
    fi
  else
    echo "Ventoy no usb disk."; exit 1
  fi
}

if ! mountpoint -q "$VERACRYPT_MNT"; then
  ventoy_sync
else
  echo "skip ventoy_sync"
fi
