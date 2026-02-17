#!/bin/bash

THEMES_DIR="$HOME/.config/hypr/themes"
CURRENT_THEME_FILE="$HOME/.config/hypr/current_theme.txt"
CURRENT_WALLPAPER_FILE="$HOME/.config/hypr/current_wallpaper.txt"
LOG_FILE="$HOME/.config/hypr/scripts/wallpaper_change.log"
UPDATE_ROFI_SCRIPT="$HOME/.config/hypr/scripts/update-rofi-background.sh"  # Updated with .sh

# Define the animation command parameters
SWWW_ANIMATION_ARGS="--transition-fps 60 --transition-step 255 --transition-type any"

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# List theme folders (sorted)
themes=$(ls -d "$THEMES_DIR"/*/ 2>/dev/null | xargs -n1 basename | sort)

if [ -z "$themes" ]; then
    notify-send "Error" "No themes found in $THEMES_DIR."
    log "Error: No themes in $THEMES_DIR."
    exit 1
fi

selected_theme=$(echo "$themes" | rofi -dmenu -p "Select Theme")

if [ -z "$selected_theme" ]; then
    exit 0
fi

# Save selected theme
echo "$selected_theme" > "$CURRENT_THEME_FILE"

# Apply first wallpaper
WALLPAPERS_DIR="$THEMES_DIR/$selected_theme/wallpapers"
mapfile -t wallpapers < <(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Error" "No wallpapers found in $WALLPAPERS_DIR."
    log "Error: No wallpapers in $WALLPAPERS_DIR."
    exit 1
fi

first_wall="${wallpapers[0]}"

# Verify image exists
if [ ! -f "$first_wall" ]; then
    notify-send "Error" "Wallpaper $first_wall does not exist."
    log "Error: Wallpaper $first_wall does not exist."
    exit 1
fi

# Apply wallpaper with swww img (with animation)
if swww img "$first_wall" $SWWW_ANIMATION_ARGS; then
    log "Success: Set wallpaper to $first_wall (with swww animation)."
    echo "$first_wall" > "$CURRENT_WALLPAPER_FILE"
else
    notify-send "Error" "Failed to set wallpaper $first_wall using swww."
    log "Error: Failed to set wallpaper $first_wall using swww."
    exit 1
fi

# Apply colors with pywal (no cache clear)
if wal -i "$first_wall" -n; then
    log "Success: Applied pywal colors for $first_wall."
    # Reload waybar silently
    killall -SIGUSR2 waybar 2>/dev/null
    # Directly update Rofi
    "$UPDATE_ROFI_SCRIPT"
    log "Success: Directly triggered Rofi background update."
else
    notify-send "Error" "Failed to apply pywal colors for $first_wall."
    log "Error: Failed to apply pywal colors for $first_wall."
    exit 1
fi

notify-send "Theme Changed" "Set theme to $selected_theme with wallpaper $(basename "$first_wall")."
