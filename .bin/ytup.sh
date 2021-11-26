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
## delay publication
# --publish-at 2021-10-07T08:24:00Z
youtube-upload \
  --title="Test title" \
  --description-file="$HOME/Videos/desc" \
  --category="People & Blogs" \
  --tags="mutter, beethoven" \
  --recording-date="$(date -u +"%Y-%m-%dT%H:%M:%SZ")" \
  --default-language="ru" \
  --default-audio-language="ru" \
  --embeddable=True \
  --privacy unlisted \
  --publish-at 2021-10-07T08:24:00Z \
  --thumbnail ~/Videos/ps.png \
  $1
