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

# URL='https://www.startpage.com/do/search?hl=pt&q='
URL='https://duckduckgo.com/?q='
QUERY=$(echo '' | dmenu -fn $FN -i -p "Search: " -nb $NB -nf $NF -sb $SB -sf $SF)

if [ -n "$QUERY" ]; then
	xdg-open "${URL}${QUERY}" 2> /dev/null
fi
