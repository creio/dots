#!/bin/bash

## transmission.sh /file_name.iso /torrent_file.iso.torrent

# Last update 2021/10/04
# https://github.com/ngosang/trackerslist
# https://ngosang.github.io/trackerslist/trackers_best.txt

TRANSDIR=$HOME/Downloads

cp -r $1 $TRANSDIR

transmission-create $1 -c "https://ctlos.github.io/changelog/" \
-t http://p4p.arenabg.com:1337/announce \
-t udp://tracker.opentrackr.org:1337/announce \
-t udp://9.rarbg.com:2810/announce \
-t udp://tracker.openbittorrent.com:6969/announce \
-t http://tracker.openbittorrent.com:80/announce \
-t http://openbittorrent.com:80/announce \
-t udp://exodus.desync.com:6969/announce \
-t udp://www.torrent.eu.org:451/announce \
-t udp://tracker.torrent.eu.org:451/announce \
-t udp://tracker.tiny-vps.com:6969/announce \
-t udp://retracker.netbynet.ru:2710/announce \
-t udp://retracker.lanta-net.ru:2710/announce \
-t udp://opentor.org:2710/announce \
-t udp://open.stealth.si:80/announce \
-t udp://camera.lei001.com:6969/announce \
-t udp://bt2.archive.org:6969/announce \
-t udp://bt1.archive.org:6969/announce \
-t https://tracker.nitrix.me:443/announce \
-t https://tracker.nanoha.org:443/announce \
-t https://tracker.lilithraws.cf:443/announce \
-o $2

transmission-remote -a $2
