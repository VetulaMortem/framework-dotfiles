#!/bin/sh

monitor_data=$(hyprctl monitors -j)
echo "$monitor_data" | jq -c '.[]' | while read -r monitor; do
    monitor_name=$(echo "$monitor" | jq -r '.name')
    workspace_id=$(echo "$monitor" | jq -r '.id')
    	$HOME/.scripts/waybarwatchdog_v3.sh $monitor_name $workspace_id &
done
