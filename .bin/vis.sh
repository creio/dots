#!/bin/bash
#=======================================================================================    
#
# Transforms cava music visualizer in a cool desktop decoration
#
# Author: Guido_Fe
#
# Dependencies (and credits): 
#   xdotool
#   cava
#   URxvt
#   devilspie
#
# Usage:
#
# To start, execute this script. To stop, execute this sctipt again.
#
# Description:
#
#   This script starts the cava music visualizer on a transparent backround through URxvt
#   ('cause it's easy to customize and support transparent foreground and background). It
#   then uses devilspie to strip it of his window decorations and rules, move it to the 
#   right place and resize it.
#   Problem: the panel doesn't allow you to focus the windows below it.
#   My solution: move cava under the screen when the mouse pointer go over
#   it, and reset its position when I move the pointer away. I accomplished this
#   behavior with xdotool.
#
#========================================================================================

#=============
# PARAMETERS TO SET
#
# Remember to don't leave spaces before and after the equal symbol

# X value of the screen resolution
Xscreen=1366

# Y value
Yscreen=768

# Offset applied to the window's vertical position
offset=5

# Height of the cava panel
h=200

# If you want to use a different cava config, set this parameter to the respective path or
# leave '' if you don't want to change it
cavaConf=''

# Set these parameters if you want to transform a default terminal color to another one.
# This is useful if you want to have semitransparent cava bars. To do so, first set the
# cava bar colors to a default one, different to the background (white, red, green...),
# form the cava config file, and assign it's color number to the inColor variable. 
# The numbers are:
#
# black='0', red='1', green='2', yellow='3', blue='4', magenta='5', cyan='6', white='7'
#
# then set the outColor variable to the color you
# want. Examples: inColor='2' outColor='[80]#223454', where 80 is the alpha level. The
# alpha level can be '0' (fully transparent), '100' (fully opaque, or a value in between.
# For outCol you can also use normal color definitions, like '#223454'.
# As usual, leave both blank ('') if you don't want to set them.
inCol='5'
outCol='[80]#fd971f'

# Set after how much time this program will check your mouse coordinates, in seconds. Higher the value, slower
# the response, but less cpu usage
mouseDelay=0.3

# After how much time the program will read a file in a loop (seconds). It will directly influence how
# fast the window under the cava panel will regain focus after hiding the panel.
fileCheck=0.1

# Time between each frame of the panel transition animation (seconds). Can be 0
trTime=0.01

# How much the panel move in each frame of the transition animation (pixels).
# It must be positive
trPixel=10
#=============

# Process parameters


if [ ! $cavaConf = '' ]; then
	cavaConf=" -p $cavaConf"
fi
if [ ! $inCol = '' -a ! $outCol = '' ]; then
	inCol=" --color$inCol"
	outCol=" $outCol"
else
	inCol=''
	outCol=''
fi
#Check if it's already running
if [ $# -eq 0 ]; then
	if [ `cat /tmp/processesToKill 2> /dev/null | wc -l` -ne 0 ]; then
		#Kills the processes of the other instance and itself
		echo "Found another $0 running, killig it and terminating..."
		kill -15 `cat /tmp/processesToKill` > /dev/null 2>&1
		rm /tmp/processesToKill
		killall cava
		exit
	else
		#It hasn't found other instances, call himself with the argument 'start'
		#to start cava
		echo "Starting the visualizer..."
		#$0 start
#UNCOMMENT THE LINE ABOVE and comment the line below if you want to debug
		setsid $0 'start' >/dev/null 2>&1 < /dev/null &
		# focus on the right window
		eval $(xdotool getmouselocation --shell)
		sleep 0.3
		xdotool windowfocus $WINDOW
		exit
	fi
elif [ "$1" = 'start' ]; then
	#The core of the program
	echo $$ >> /tmp/processesToKill
	#File that xdotool uses to communicate when the mouse go over the panel
	isTriggeredFile='/tmp/isTriggered'
	echo 0 > $isTriggeredFile
	#Write the conf file for devilspie
	echo '(and
	    (is (window_name) "cava")
	    (is (window_class) "URxvt")
	    (begin
	        (stick)
	        (above)
	        (pin)
	        (undecorate)
	        (skip_pager)
	        (skip_tasklist)
	        (wintype "dock")
	        (geometry "'$Xscreen'x'$h'+0+'`expr $Yscreen - $h + $offset`'")
	    )
	)' > /tmp/cava.ds
	#Start urxvt and execute cava in it. Change the color white to the one chosen
	urxvt -bg "[0]red"$inCol$outCol -b 0 -depth 32 +sb -e cava$cavaConf &
	wPid=$!
	echo $wPid >> /tmp/processesToKill
	# Starts devilspie, that will move and resize the window
	devilspie /tmp/cava.ds > /dev/null &
	echo $! >> /tmp/processesToKill
	# Get the window id (!= pid) of the instance
	sleep 0.5
	pids=`xdotool search --class "URxvt"`
	for pid in $pids; do
		name=`xdotool getwindowname $pid`
		if [[ $name == *"cava"* ]]; then
			wId=$pid
		fi
	done
	# Wait that the mouse go over the window. When it does, write 1 to $isTriggeredFile
	# and move the window over the bottom edge of the screen, hiding it
	xdotool behave $wId mouse-enter windowmove x $Yscreen exec sh -c "echo 1 > $isTriggeredFile" > /dev/null &
	echo $! >> /tmp/processesToKill
	# Infinite loop hide/show
	while [ 0 -eq 0 ]; do
		# what for the mouse to go over the panel
		while [ `cat $isTriggeredFile` = 0 ]
		do
			sleep $fileCheck
		done
		echo 0 > $isTriggeredFile
		# focus on the right window
		eval $(xdotool getmouselocation --shell)
		xdotool windowfocus $WINDOW
		cursorExited=0;
		# wait for the mouse to leave the bottom of the screen
		while [ $cursorExited -eq 0 ]; do
		    eval $(xdotool getmouselocation --shell)
		    if [ $Y -lt `expr $Yscreen - $h + $offset` ]; then
			# Reset cava position
			cursorExited=1
			Yd=$Yscreen
			Ydefault=`expr $Yscreen - $h + $offset`
			while [ $Yd -gt $Ydefault ]; do
				Yd=`expr $Yd - $trPixel`
				sleep $trTime
				xdotool windowmove $wId x $Yd
			done
			xdotool windowmove $wId x $Ydefault
		    fi
		    sleep $mouseDelay
		done
	done
fi
