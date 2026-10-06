#!/bin/bash
NEW_WALLPAPER=$(realpath "$1")
QUICKSHELL_DIR="$HOME/.config/quickshell"
OVERRIDES_FILE="$QUICKSHELL_DIR/overrides.json"

# Prüfen, ob ein manuelles Theme für dieses Bild existiert
MANUAL_THEME=$(jq -r --arg img "$NEW_WALLPAPER" '.[$img] // empty' "$OVERRIDES_FILE")

if [ -n "$MANUAL_THEME" ] && [ -f "$MANUAL_THEME" ]; then
    echo "Lade manuelles Theme..."
    cp -v "$MANUAL_THEME" "$QUICKSHELL_DIR/ThemeColors.qml"
    themename=$(basename $MANUAL_THEME .qml)
    cp -v $HOME/.assets/kitty_themes/$themename.conf $HOME/.config/kitty/theme.conf 
else
    echo "Lasse Wallust Farben generieren..."
    wallust run "$NEW_WALLPAPER"
fi
