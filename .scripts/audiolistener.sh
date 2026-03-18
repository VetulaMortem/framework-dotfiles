#!/usr/bin/env bash

# Socket used by PipeWire for event notifications
SOCKET="$XDG_RUNTIME_DIR/pipewire-0"

# Small debounce to avoid OSD spam
DEBOUNCE_MS=150
LAST_CALL=0

socat -u UNIX-CONNECT:"$SOCKET" - | while read -r line; do
    # PipeWire messages are binary-ish; volume changes contain "ParamProps"
    echo "$line"
    #if echo "$line" | grep -q "ParamProps"; then
        #NOW=$(date +%s%3N)
        #if (( NOW - LAST_CALL > DEBOUNCE_MS )); then
            #swayosd-client --output-volume show
        #    LAST_CALL=$NOW
        #fi
    #fi
done
