#!/bin/bash

CLEAN_ALL=(
~/.bzr.log
~/.ncmpcpp/error.log
~/.pki
~/.xsession-errors.old
~/.cache/{babl,gegl-0.2,google-chrome,gstreamer-1.0,menu}
~/.local/share/{gegl-0.2,recently-used.xbel}
)
CLEAN_DIR=(
~/.cache/thumbnails/
~/.local/share/Trash/
)

clean_all()
{
  echo "clean all"
  for i in "${CLEAN_ALL[@]}"; do
    [[ $i ]] && rm -rfv $i
  done
}

clean_d()
{
  echo "clean dir"
  for i in "${CLEAN_DIR[@]}"; do
    [[ $i ]] && find $i -mindepth 1 -delete
  done
}

clean_all
clean_d
