#!/usr/bin/env bash

# Öffnet das Eww Overlay, wartet 2.5 Sekunden und schließt es wieder
eww -c $HOME/.config/eww/charging open charge-popup
sleep 2.5
eww -c $HOME/.config/eww/charging close charge-popup
