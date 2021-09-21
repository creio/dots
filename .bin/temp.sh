#!/bin/bash

if [[ $EUID -ne 0 ]]; then
	echo "This script must be run as root." >&2
	exit 1
fi

cpu_temp=$(($(cat /sys/class/thermal/thermal_zone0/temp) / 1000))
echo "---cpu"
echo "${cpu_temp} C"

echo "---nvme"
smartctl -A /dev/nvme0n1 | grep Temperature: | awk '{ print ""$2"","C"}'

echo "---hdd"
smartctl -A /dev/sda | grep Celsius | awk '{ print ""$10"","C"}'

echo "---nvidia"
nvidia-smi --query-gpu=temperature.gpu --format=csv,noheader | awk '{ print ""$1"","C"}'
