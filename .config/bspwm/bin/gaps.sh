#!/usr/bin/env bash

status=$(bspc config -d focused window_gap)

if [ $status = 0 ]; then
  bspc config border_width               2
  bspc config -d focused window_gap      10
  bspc config -d focused top_padding     0
  bspc config -d focused bottom_padding  0
  bspc config -d focused left_padding    0
  bspc config -d focused right_padding   0
else
  bspc config border_width               2
  bspc config -d focused window_gap      0
  bspc config -d focused top_padding     0
  bspc config -d focused bottom_padding  0
  bspc config -d focused left_padding    0
  bspc config -d focused right_padding   0
fi
