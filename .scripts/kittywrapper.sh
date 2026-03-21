#!/bin/bash
XKB_DEFAULT_LAYOUT=de gamescope -f -w 2256 -h 1504 -r 60 -- /usr/bin/kitty -o tab_bar_style=hidden $1
