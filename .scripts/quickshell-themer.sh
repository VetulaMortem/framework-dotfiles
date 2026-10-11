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
    cp -v $HOME/.assets/cava_themes/$themename $HOME/.config/cava/themes/framework
    cp -v $HOME/.assets/nvim_themes/$themename.lua $HOME/.config/nvim/lua/theme/framework.lua
    cp -v $HOME/.assets/hypr_themes/$themename.lua $HOME/.config/hypr/lua/colorTheme.lua
else
    echo "Lasse Wallust Farben generieren..."
    wallust run "$NEW_WALLPAPER"
fi

cd $HOME/.assets
rm eDP-1
ln -s $NEW_WALLPAPER eDP-1
