#!/bin/bash

# https://github.com/ngosang/trackerslist

TRANSDIR=$HOME/Downloads

cp -r $1 $TRANSDIR

transmission-create $1 -c "https://ctlos.github.io/wiki/changelog/" -t udp://tracker.openbittorrent.com:80 -t udp://tracker.leechers-paradise.org:6969/announce -t udp://tracker.coppersurfer.tk:6969/announce -t udp://tracker.opentrackr.org:1337/announce -t udp://tracker.internetwarriors.net:1337/announce -t udp://explodie.org:6969/announce -t udp://tracker.ds.is:6969/announce  -o $2

transmission-remote -a $2
