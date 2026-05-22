#!/usr/bin/env bash

echo "triggered $(date)" >> /tmp/yubi-lock.log

export XDG_RUNTIME_DIR="/run/user/$(id -u)"
export WAYLAND_DISPLAY=$(ls "$XDG_RUNTIME_DIR" | grep wayland | head -n1)

echo "runtime=$XDG_RUNTIME_DIR display=$WAYLAND_DISPLAY" >> /tmp/yubi-lock.log
sleep 1
pidof hyprlock || hyprlock 
