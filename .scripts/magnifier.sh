#!/bin/bash
zoomstate=$1
magnification=$2
currentzoom=`hyprctl getoption cursor:zoom_factor | grep float | awk '{print $2}'`
newzoom=$currentzoom
case $zoomstate in
	+)
	newzoom=`bc -l <<< "$currentzoom + $magnification"`
	;;
	-)
	newzoom=`bc -l <<< "$currentzoom - $magnification"`
	;;
	*)
	echo "ERROR"
	;;
esac
hyprctl dispatch 'hl.config({cursor = {zoom_factor = $newzoom}})'
