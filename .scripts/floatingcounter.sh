#!/bin/bash
activeWS=$1
export XDG_RUNTIME_DIR="/run/user/1000"
export DBUS_SESSION_BUS_ADDRESS="unix:path=${XDG_RUNTIME_DIR}/bus"
export HYPRLAND_INSTANCE_SIGNATURE=$(ls -1t /run/user/1000/hypr/*/hyprland.lock 2>/dev/null | xargs -I% dirname % | xargs -I% basename %)
floating=0
total=0
while read -r client; do
    inittitel=$(echo "$client" | jq '.initialTitle')
    workspace=$(echo "$client" | jq '.workspace.id')
    monitorWindow=$(echo "$client" | jq '.monitor')
        is_floating=$(echo "$client" | jq '.floating')
        if [[ $workspace == $activeWS ]];then
		((total++))
		if [[ "$is_floating" == "true" || "$is_floating" == "1" ]]; then
		    ((floating++))
		fi
	fi
done < <(hyprctl clients -j | jq -c '.[]')
#notify-send $activeWS $floating
echo $total" - "$floating  | bc
