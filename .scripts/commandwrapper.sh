#!/bin/bash
command=$1
initialClasses=$(hyprctl clients -j | jq '.[]' | jq '.initialClass')
relevantClasses=$(echo $initialClasses | grep -E "gamescope|steam_app" -c)
if [[ $relevantClasses -eq 0 ]];then
	eval $1
else
	notify-send "PROHIBITET EXECUTION"
fi
