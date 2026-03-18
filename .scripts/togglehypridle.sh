#!/bin/bash
running=$(systemctl --user status hypridle.service | grep "Active:.*running" | wc -l)

case $running in
	0)
		systemctl --user start hypridle.service
		notify-send "Hypridle toggled on"
		;;
	1)
		systemctl --user stop hypridle.service
		notify-send "Hypridle toggled off"
		;;
esac
