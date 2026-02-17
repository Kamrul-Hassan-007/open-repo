#!/bin/bash

THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current_theme.txt"
CURRENT_WALLPAPER_FILE="$HOME/.config/hypr/current_wallpaper.txt"
LOG_FILE="$HOME/.config/hypr/scripts/wallpaper_change.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Load current theme, default to theme1 if missing
current_theme=$(cat "$CURRENT_THEME_FILE" 2>/dev/null || echo "theme1")
if [ ! -d "$THEMES_DIR/$current_theme/wallpapers" ]; then
    log "Theme $current_theme not found, using theme1."
    echo "theme1" > "$CURRENT_THEME_FILE"
    current_theme="theme1"
fi

# Get wallpapers and find next one
WALLPAPERS_DIR="$THEMES_DIR/$current_theme/wallpapers"
wallpapers=($(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | sort))
if [ ${#wallpapers[@]} -eq 0 ]; then
    log "No wallpapers in $WALLPAPERS_DIR."
    notify-send "Error" "No wallpapers found."
    exit 1
fi

current_wall=$(cat "$CURRENT_WALLPAPER_FILE" 2>/dev/null || echo "")
index=-1
for i in "${!wallpapers[@]}"; do
    if [[ "${wallpapers[$i]}" == "$current_wall" ]]; then
        index=$i
        break
    fi
done
next_index=$(( (index + 1) % ${#wallpapers[@]} ))
next_wall="${wallpapers[$next_index]}"

# Apply wallpaper
if swww img "$next_wall" 2>/dev/null; then
    log "Set wallpaper to $next_wall."
    echo "$next_wall" > "$CURRENT_WALLPAPER_FILE"
else
    log "Failed to set wallpaper $next_wall."
    notify-send "Error" "Failed to change wallpaper."
    exit 1
fi

# Apply colors
if wal -i "$next_wall" -n -q 2>/dev/null; then
    log "Applied pywal colors."
    killall -SIGUSR2 waybar 2>/dev/null
else
    log "Failed to apply pywal colors."
    notify-send "Error" "Color update failed."
    exit 1
fi

notify-send "Wallpaper Changed" "Set to $(basename "$next_wall")."
