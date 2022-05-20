#!/usr/bin/env bash

if [ "$1" == "-u" ]; then
  pactl unload-module module-loopback
  pactl unload-module module-null-sink
else
  pactl load-module module-null-sink sink_name=combined
  # pactl list sources|grep Name
  pactl load-module module-loopback source=alsa_input.pci-0000_00_1b.0.analog-stereo sink=combined
  pactl load-module module-loopback source=alsa_output.pci-0000_00_1b.0.analog-stereo.monitor sink=combined
fi
