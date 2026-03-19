#!/bin/bash
XKB_DEFAULT_LAYOUT=de gamescope -W 2256 -H 1504 -r 60 -- /usr/bin/kitty -o tab_bar_style=hidden $1
