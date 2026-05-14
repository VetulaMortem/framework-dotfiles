#!/bin/bash

# Detect if on AC power
if grep -q 1 /sys/class/power_supply/AC*/online 2>/dev/null; then
    # Plugged in
    systemctl suspend
else
    # On battery
    systemctl suspend-then-hibernate
fi
