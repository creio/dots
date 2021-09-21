#!/bin/bash
set -e
# [[ -f ~/.env ]] && . ~/.env

if [[ $EUID -ne 0 ]]; then
  echo "run root" && exit 1
fi

run_time=$(date +%Y-%m-%d-%H-%M-%S)
echo "Start: $run_time"

[[ ! -d /tmp/dump ]] && mkdir /tmp/dump
mount /dev/sda4 /tmp/dump

if mountpoint -q /tmp/dump; then
  rsync -caAXu --delete --delete-excluded --exclude={"lost+found/*",".Trash*"} /media/files/ /tmp/dump/
else
  sudo -u creio DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -u critical -t 0 "dump.sh" "Rsync /dev/sda4 ERROR!" && exit
fi
umount -Rfl /tmp/dump
rm -rf /tmp/dump

sudo -u creio DISPLAY=:0 DBUS_SESSION_BUS_ADDRESS=unix:path=/run/user/1000/bus notify-send -t 0 "dump.sh" "Rsync /dev/sda4 Done!"
# echo "Succes!"
exit 0
