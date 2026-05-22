#!/bin/sh
monitorName=$1
monitorID=$2
waybar_pid=""

start_waybar() {
    if [ -z "$waybar_pid" ] || ! kill -0 "$waybar_pid" 2>/dev/null; then
        waybar -c $HOME/.config/waybar/"config-"$monitorName & 
        waybar_pid=$!
    fi
}

stop_waybar() {
    if [ -n "$waybar_pid" ] && kill -0 "$waybar_pid" 2>/dev/null; then
        kill "$waybar_pid"
        waybar_pid=""
    fi
}


handle() {
floating=0
total=0
specialparam=0
#initialTitle: Steam Big Picture Mode  
   case $1 in
   focusedmonv2*|*changefloatingmode*|workspace*|activespecial*|openwindow*|closewindow*)
   #*)
   activeworkspaceID=`hyprctl activeworkspace -j | jq -r '"\(.id)"'`
   activeMonitor=`hyprctl activeworkspace -j | jq '.monitorID'`
   echo $monitorID " - " $activeMonitor 
while read -r client; do
    inittitel=$(echo "$client" | jq '.initialTitle')
    workspace=$(echo "$client" | jq '.workspace.id')
    monitorWindow=$(echo "$client" | jq '.monitor')
    if [[ "$monitorWindow" -eq "$monitorID" ]] && [[ "$activeworkspaceID" -eq "$workspace" ]] ; then
	    ((total++))
        is_floating=$(echo "$client" | jq '.floating')
        if [[ "$is_floating" == "true" || "$is_floating" == "1" ]]; then
            ((floating++))
        fi
	if [[ $(echo "$inittitel" | egrep "Steam Big Picture Mode" -c) == "1" ]];then
	    specialparam=1
	fi
	if [[ $workspace = "10" ]];then
	    specialparam=1
	fi
    fi
done < <(hyprctl clients -j | jq -c '.[]')

echo "PID:"$waybar_pid" Active:"$activeMonitor" Controlling:"$monitorID " - Workspace:"$workspace" active:"$activeworkspaceID  
relevantWindows=`expr $total - $floating`
	if [[ $monitorID -eq $activeMonitor ]];then
		if [ $relevantWindows -eq 1 ] || [ $specialparam -eq 1 ];then
			echo "CLOSE WAYBAR"
			stop_waybar
		else
			echo "OPEN WAYBAR"
			start_waybar
		fi
	echo $monitorID " AA"
	fi
	;;
  esac
}
start_waybar
socat -U - UNIX-CONNECT:$XDG_RUNTIME_DIR/hypr/$HYPRLAND_INSTANCE_SIGNATURE/.socket2.sock | while read -r line; do handle "$line"; done
