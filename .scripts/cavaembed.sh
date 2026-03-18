#!/bin/bash
killall cava
if [[ $(date "+%d.%m") == "25.12" ]];then
	kitty +kitten panel --edge=background -o background_opacity=0.0 -o cursor_shape=beam snowmachine snow
else
	kitty +kitten panel --edge=background -o background_opacity=0.0 cava
fi
