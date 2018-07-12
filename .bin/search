#!/bin/bash

# URL='https://yubnub.org/parser/parse?command='

URL='https://duckduckgo.com/?q='
QUERY=$(cat ~/.cache/search_history | rofi -dmenu -p "Search")
if [ -n "$QUERY" ]; then
    grep -q "$QUERY"  "$HOME/.cache/search_history"
    echo $QUERY >> ~/.cache/search_history_temp && sort -u ~/.cache/search_history_temp > ~/.cache/search_history
  xdg-open "${URL}${QUERY}" 2> /dev/null
fi
