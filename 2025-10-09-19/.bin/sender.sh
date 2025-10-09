#!/usr/bin/env bash
# @Author: Alex Creio <mailcreio@gmail.com>
# @Date:   18.05.2022 11:59
# @Last Modified by:   creio
# @Last Modified time: 19.05.2022 21:23

# curl -Ls https://cvc.srht.site/posts/atom.xml | awk '/<\<entry>/,/<\/entry>/ {print}' | ./atom.sh

# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | iconv -f koi8-r -t utf-8 | ./rss.sh

# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | xmllint --xpath '/rss/channel/item[1]' -
# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | xmllint --xpath '/rss/channel/item[1]/title/text()' -

# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | xmlstarlet sel -t -m '/rss/channel/item' -v title -n
# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | xmlstarlet sel -t -m '/rss/channel/item[1]' -v title -n
# curl -Ls http://www.opennet.ru/opennews/opennews_all_noadv.rss | xmlstarlet sel -t -m '/rss/channel/item' -v title -n | head -n 5

[[ -s ~/.env ]] && . ~/.env

urls=(
"arch|https://www.archlinux.org/feeds/news/"
"opennet|http://www.opennet.ru/opennews/opennews_all_noadv.rss"
)

get_rss() {
    RSS_CACHE_DIR=$HOME/.cache/rss-temps
    [[ ! -d $RSS_CACHE_DIR ]] && mkdir -p $RSS_CACHE_DIR
  # cat rss.tmp
  for item in "${urls[@]}"; do
    title=$(cat $RSS_CACHE_DIR/"${item%|*}".tmp)
    get_title=$(curl -Ls "${item#*|}" | xmlstarlet sel -t -m '/rss/channel/item[1]' -v title -n)
    if [[ $get_title != $title ]]; then
      echo "$get_title" > $RSS_CACHE_DIR/"${item%|*}".tmp
      link=$(curl -Ls "${item#*|}" | xmlstarlet sel -t -m '/rss/channel/item[1]' -v link -n)
      format_title=$(echo $get_title | sed -e 's/&lt;/\</g' -e 's/&gt;/\>/g' \
        -e 's/[\(^$?\~\!\|()<>{}%-.#_]/\\&/g')
    fi
    message() {
      if [[ $format_title && $link ]]; then
        echo "[$format_title]($link)"
      fi
    }
    if [[ $get_title != $title ]]; then
      curl -so /dev/null -X POST https://api.telegram.org/bot$TG_KEY/sendMessage \
        -d parse_mode=MarkdownV2 \
        -d chat_id=$TG_CH_ID \
        -d disable_web_page_preview=True \
        -d text="$(message)"
      echo "send "${item%|*}" done"
    fi
  done
}
get_rss
