#!/bin/bash
cur=$(brightnessctl g 2> /dev/null)
max=$(brightnessctl m 2> /dev/null)
onePerc=$(echo $max" / 100" | bc)
percent=$(echo $cur" / "$onePerc | bc )
echo $cur" "$max" "$percent

