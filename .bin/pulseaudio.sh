#!/usr/bin/env bash

micro="alsa_input.pci-0000_00_1b.0.analog-stereo"
# micro=$(pactl get-default-source | sed 's/\.[^\.]*$//')

pactl set-source-port 0 analog-input-rear-mic

## deps: noise-suppression-for-voice
if [[ ! $(pactl list modules short | grep module-null-sink) && $(pacman -Qs noise-suppression-for-voice) ]]; then
  pactl load-module module-null-sink sink_name=mic_denoised_out rate=48000
  pactl load-module module-ladspa-sink sink_name=mic_raw_in sink_master=mic_denoised_out label=noise_suppressor_mono plugin=librnnoise_ladspa.so control=50,200,0,0,0
  echo "aasd"
  # pactl set-default-source mic_denoised_out.monitor

  pactl load-module module-loopback source=$micro sink=mic_raw_in channels=1 source_dont_move=true sink_dont_move=true
elif [[ $1 == "-u" ]]; then
  pactl unload-module module-loopback
  pactl set-default-source $micro
  pactl unload-module module-ladspa-sink
  pactl unload-module module-null-sink
fi
