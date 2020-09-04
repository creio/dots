#!/bin/bash

TRANSDIR=$HOME/Downloads

cp -r $1 $TRANSDIR

transmission-create $1 -t udp://tracker.openbittorrent.com:80 -o $2

transmission-remote -a $2
