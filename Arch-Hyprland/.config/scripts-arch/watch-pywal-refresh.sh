#!/bin/bash
# install inotify-tools to work. 

COLORS_DIR="$HOME/.cache/wal"
COLORS_FILE="colors-waybar.css"
UPDATE_ROFI_SCRIPT="$HOME/.config/hypr/scripts/update-rofi-background.sh"  # Updated with .sh
LOG_FILE="$HOME/.config/hypr/scripts/wallpaper_change.log"  # Reuse your log

# Log function
log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Monitor directory for changes to colors-waybar.css
inotifywait -m -e create,modify "$COLORS_DIR" | while read path action file; do
    if [ "$file" = "$COLORS_FILE" ]; then
        pkill -SIGUSR2 waybar
        pywalfox update
        "$UPDATE_ROFI_SCRIPT"  # Update Rofi theme
        log "Success: Triggered Rofi background update after pywal change"
    fi
done
