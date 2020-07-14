#!/bin/sh

export FZF_DEFAULT_OPTS='
--height=30%
--layout=reverse
--prompt="Manual: "
--preview="echo {1} | sed -E \"s/^\((.+)\)/\1/\" | xargs -I{S} man -Pcat {S} {2} 2>/dev/null"'

while getopts ":s:" opt; do
    case $opt in
        s ) SECTION=$OPTARG; shift; shift;;
        \?) echo "Invalid option: -$OPTARG" >&2; exit 1;;
        : ) echo "Option -$OPTARG requires an argument" >&2; exit 1;;
    esac
done

manual=$(apropos -s ${SECTION:-''} ${@:-.} | \
    grep -v -E '^.+ \(0\)' |\
    awk '{print $2 "    " $1}' | \
    sort | \
    fzf  | \
    sed -E 's/^\((.+)\)/\1/')

[ -z "$manual" ] && exit 0
man $manual
