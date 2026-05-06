#!/usr/bin/env bash

. ~/.env

imap_url=$IMAP_URL
imap_email=$IMAP_EMAIL # %40 == @
imap_pass=$IMAP_PASS

# https://stackoverflow.com/a/49430246
# список UID непрочитанных писем (формат: "* SEARCH 4 5 12")
result=$(curl --max-time 10 -sS --url "imaps://$imap_email:$imap_pass@$imap_url:993/INBOX" -X "SEARCH UNSEEN" 2>&1 | grep -oE '[0-9]+' | wc -l)
[[ $result == 0 ]] && echo "" || echo $result