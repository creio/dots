#!/usr/bin/env bash
# by mhess

# Font
FN='ClearSansMedium:size=10'
# Background Commands
NB='#111113'
# Foreground Commands
NF='#FFF'
# Background Prompt
SB='#5a74ca'
# Foreground Prompt
SF='#FFF'

CACHEDIR="/tmp/dyou"
PLAYER="mpv"

# Style of dmenu
search=$(echo | dmenu -fn $FN -i -p "YouTube >" -nb $NB -nf $NF -sb $SB -sf $SF | tr " " +)

[ -z ${search} ] && exit

[ -d "${CACHEDIR}/${search}" ] || mkdir -p ${CACHEDIR}/${search}

curl -so $CACHEDIR/$search/search.txt "https://www.youtube.com/results?hl=en&search_query=$search"

# Get video titles
cat $CACHEDIR/$search/search.txt |\
grep "Duration" |\
awk ' /yt-lockup-title/ {print $13 " " $14 " " $15 " " $16 " " $17 " " $18 " " $19 " " $20 " " $21 " " $22 " " $23 " " $24 " " $25 " " $26 " " $27 " " $28 " " $29 " " $30}' |\
sed 's/aria-describedby="description-id.*//g;s/title=//g;s/"//g;s/spf-link//g;s/data-session-link=itct*.//;s/spf-prefetch//g;s/rel=//g;s/"//g;s/&amp;/\&/g;s/\&quot\;/\"/g'|\
sed s/\&#39\;/"'"/g |\
nl -ba -w 3  -s '. ' > $CACHEDIR/$search/titles.txt || return 1

# Get video urls
cat $CACHEDIR/$search/search.txt |\
sed -rn 's/^.*yt-lockup-title.{6}href="(.{20})" class.*$/\1/p' |\
sed 's/^/https:\/\/www.youtube.com/' |\
nl -ba -w 3  -s '. ' > $CACHEDIR/$search/urls.txt || return 1

# Print 20 first video titles for the user to choose from
get_video=$(cat $CACHEDIR/$search/titles.txt | dmenu -fn $FN -i -p "YouTube >" -nb $NB -nf $NF -sb $SB -sf $SF -l 30)

[ -z ${get_video} ] && exit

# Play the video with your favorite player
$PLAYER $(sed -n $(echo ${get_video} | grep -Eo "^[[:digit:]]+")p < $CACHEDIR/$search/urls.txt | awk '{print $2}') > /dev/null 2>&1 &
