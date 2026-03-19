#!/bin/bash
sleep 1
volume=$(wpctl get-volume @DEFAULT_SINK@  | cut -d ":" -f2 | cut -d "[" -f1)
muted=$(wpctl get-volume @DEFAULT_SINK@ | grep -i muted -c)
wpctl set-volume @DEFAULT_SINK@ 1
wpctl set-mute @DEFAULT_SINK@ 0
/home/vetula/.scripts/kittywrapper.sh ncspot
wpctl set-volume @DEFAULT_SINK@ $volume
wpctl set-mute @DEFAULT_SINK@ $muted
