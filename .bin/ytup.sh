#!/bin/bash
#
### https://github.com/tokland/youtube-upload
#
# sudo pip install --upgrade google-api-python-client oauth2client progressbar2
# git clone https://github.com/tokland/youtube-upload
# cd youtube-upload
# sudo python setup.py install

# --description="test desc vk: https://vk.com/ctlos"
# --privacy (public | unlisted | private)
# --thumbnail ~/Videos/ps.png
# --playlist="Linux" \
## delay publication GMT-0 (-3h MSK) date -u +"%Y-%m-%dT%H:%M:00Z"
# --publish-at 2021-10-07T08:24:00Z
youtube-upload \
  --title="LINUX KDE DE REVIEW | ОБЗОР" \
  --privacy public \
  --tags="linux, archlinux" \
  --publish-at $(date -d "1 hour" -u +"%Y-%m-%dT%H:%M:00Z") \
  --description-file="$HOME/Videos/desc" \
  --recording-date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --playlist="Linux" \
  --category="People & Blogs" \
  --default-language="ru" \
  --default-audio-language="ru" \
  --embeddable=True \
  $1
