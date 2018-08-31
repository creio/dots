#!/bin/bash

function gen_workspaces()
{
    i3-msg -t get_workspaces | tr ',' '\n' | grep "name" | sed 's/"name":"\(.*\)"/\1/g' | sort -n
}


WORKSPACE=$( (echo Hiden; gen_workspaces)  | rofi -dmenu -p "Select workspace")

if [ x"Hiden" = x"${WORKSPACE}" ]
then
    $HOME/.bin/i3_empty_workspace.sh
elif [ -n "${WORKSPACE}" ]
then
    i3-msg workspace "${WORKSPACE}"
fi
