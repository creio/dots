#!/usr/bin/bash

if [[ "$1" == "-s" ]]; then
  res=$(ps -eo rss,pid,euser,args:100 --sort %mem | grep -v grep | grep -i $@ | \
    awk '{printf $1/1024; $1=""; print }' | \
    sed '/mem.sh/d' | awk '{print $1}' | xargs | tr ' ' '+' | bc)
  echo $res MB
else
  ps -eo rss,pid,euser,args:100 --sort %mem | grep -v grep | grep -i $@ | \
  sed '/mem.sh/d' | awk '{printf $1/1024 " MB"; $1=""; print }'
fi
