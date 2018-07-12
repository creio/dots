#!/bin/bash
WMCTRL=`which wmctrl`;
GREP=`which grep`;
APPLICATION=$1;
BASENAME=`basename $APPLICATION | tr "[:upper:]" "[:lower:]"`
FOUND=0;

function findwindow {
    IFS=$'\n';
    MAX_MATCHES=0;
    for RUNNING in `$2 -l -x | awk '{print $1, $3}' | tac`; do
        MATCH_COUNT=`echo $RUNNING | tr "[:upper:]" "[:lower:]" | $3 -o $1 | wc -l`
        if [ $MATCH_COUNT -gt $MAX_MATCHES ]; then
            MAX_MATCHES=$MATCH_COUNT
            WINDOW_ID=`echo $RUNNING | cut -c1-11`
            FOUND=1;
        fi;
    done
}

findwindow $BASENAME $WMCTRL $GREP; 
if [ $FOUND -eq 0 ]; then
    $APPLICATION &
else
    $WMCTRL -i -a $WINDOW_ID
fi