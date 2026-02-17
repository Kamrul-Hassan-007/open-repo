#!/bin/bash

CHANGE_SCRIPT="$HOME/.config/hypr/scripts/change_wallpaper_next.sh"
LOG_FILE="$HOME/.config/hypr/scripts/wallpaper_change.log"

log() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $1" >> "$LOG_FILE"
}

# Check if script exists
if [ ! -f "$CHANGE_SCRIPT" ]; then
    log "Change script not found at $CHANGE_SCRIPT."
    notify-send "Error" "Auto-change script missing."
    exit 1
fi

while true; do
    if "$CHANGE_SCRIPT" --no-animation; then
        log "Wallpaper changed successfully."
    else
        log "Wallpaper change failed, retrying."
        notify-send "Warning" "Auto-change failed, retrying."
    fi
    sleep 600  # 10 minutes
done
