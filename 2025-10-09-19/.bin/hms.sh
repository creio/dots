#!/bin/bash
times=("$@")
for t in ${times[@]}; do
	(( minutes+=${t%%:*}*60, minutes+=${t##*:} ))
done
((hour=$minutes/60))
((min=$minutes-$hour*60))
((seconds=$minutes*60))
echo "---------"
echo $hour:$min
echo "----------------------"
eval "echo $(date -ud "@$seconds" +'$((%s/3600/24)) d %H h %M min %S sec')"
