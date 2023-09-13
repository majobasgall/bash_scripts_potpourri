#!/bin/bash
#This script allows to enable/disable webcam

#Usage: ./webcam_state.sh e	./webcam_state.sh d

if [ -z "$1" ]
 then
	echo "No argument supplied. Usage: ./webcam e (enable)	./webcam d (disable)"
 exit
fi


if [ "$1" = "e" ]
then
	sudo modprobe uvcvideo
elif [ "$1" = "d" ]
then
	sudo rmmod -f uvcvideo
fi
