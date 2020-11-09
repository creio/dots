#!/usr/bin/env sh

# Font
FN='ClearSansMedium:size=11'
# Background Commands
NB='#111113'
# Foreground Commands
NF='#FFF'
# Background Prompt
SB='#5A74CA'
# Foreground Prompt
SF='#FFF'

urlencode() {
    old_lc_collate=$LC_COLLATE
    LC_COLLATE=C

    local length="${#1}"
    for (( i = 0; i < length; i++ )); do
        local c="${1:i:1}"
        case $c in
            [a-zA-Z0-9.~_-]) printf "$c" ;;
            ' ') printf "%%20" ;;
            *) printf '%%%02X' "'$c" ;;
        esac
    done
    LC_COLLATE=$old_lc_collate
}


# URL='https://www.startpage.com/do/search?hl=pt&q='
URL='https://duckduckgo.com/?q='
QUERY=$(urlencode "$(echo '' | dmenu -fn $FN -i -p "Search: " -nb $NB -nf $NF -sb $SB -sf $SF)")

if [ -n "$QUERY" ]; then
  xdg-open "${URL}${QUERY}" 2> /dev/null
fi
