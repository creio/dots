#!/bin/bash

folderName=$1

yt-dlp \
    --extractor-args "tiktok:secuid=$2" \
    --yes-playlist \
    -i \
    --download-archive "$folderName/arx.txt" \
    --playlist-reverse \
    --progress \
    -P "$folderName" \
    -o "%(autonumber+0)04d_--_%(fulltitle)s_-_%(channel)s_--_[%(webpage_url_domain)s-%(id)s].%(ext)s" \
    --restrict-filenames \
    --trim-filenames 200 \
    https://www.tiktok.com/@$folderName
