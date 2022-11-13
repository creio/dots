#!/usr/bin/env bash

. ~/.env

imap_url=$IMAP_URL
imap_email=$IMAP_EMAIL # %40 == @
imap_pass=$IMAP_PASS

# https://stackoverflow.com/a/49430246
mail_res=$(curl -s --url "imaps://$imap_email:$imap_pass@$imap_url:993/inbox/" -X 'fetch 1:* (UID FLAGS)' | grep -v 'Seen' | wc -l)

if [[ $mail_res > '0' ]]; then
  echo $mail_res
else
  echo ""
fi
