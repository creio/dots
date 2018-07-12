#!/bin/bash
#
# Author: Twily     2014
#

unhide_cursor() { printf "\e[?25h"; }
trap unhide_cursor EXIT

STRW=`expr 6 \* 3 + 2`  # String length "00:00:00" in character blocks produced by toilet font
STRH=3                  # String height "00:00:00" in character blocks produced by toilet font
SPACEW=3                # "Space" length in character block produced by toilet font

# This will center the clock, but resizing will leave artifacts
function center {
    TW=`tput -S <<< cols`
    TH=`tput -S <<< lines`

    A1=`expr $TH - $STRH`
    A1=`expr $A1 / 2`
    A2=`expr $TW - $STRW`
    A2=`expr $A2 / 2`
    A2=`expr $A2 / $SPACEW`
}

clear
center
printf "\e[?25l"
while true; do
    printf "\033[;H"

    B2=""
    for i in `seq 1 $A1`; do echo ""; done
    for i in `seq 1 $A2`; do B2="$B2 "; done

    toilet -f future -t --g <<< "$B2`date +'%H:%M:%S'`"
    sleep .1
done
