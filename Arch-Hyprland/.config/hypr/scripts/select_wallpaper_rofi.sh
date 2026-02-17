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

# Function to safely load current theme
load_current_theme() {
    if [ ! -f "$CURRENT_THEME_FILE" ] || [ ! -s "$CURRENT_THEME_FILE" ]; then
        log "Warning: Current theme file missing or empty, setting to theme1."
        echo "theme1" > "$CURRENT_THEME_FILE"
    fi
    current_theme=$(cat "$CURRENT_THEME_FILE")
    
    # Verify theme exists and force theme1 if invalid
    if [ ! -d "$THEMES_DIR/$current_theme" ]; then
        log "Error: Theme $current_theme directory does not exist. Forcing theme1."
        notify-send "Error" "Theme $current_theme not found. Defaulting to theme1."
        echo "theme1" > "$CURRENT_THEME_FILE"
        current_theme="theme1"
    fi
    echo "$current_theme"
}

# --- Main Execution ---

current_theme=$(load_current_theme)

WALLPAPERS_DIR="$THEMES_DIR/$current_theme/wallpapers"

# List wallpapers (full paths, sorted, handles spaces/symbols)
mapfile -t wallpapers < <(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) 2>/dev/null | sort)

# List only basenames for Rofi (using -printf to get filename safely)
mapfile -t wallpaper_names < <(find "$WALLPAPERS_DIR" -maxdepth 1 -type f \( -iname "*.jpg" -o -iname "*.png" \) -printf "%f\n" 2>/dev/null | sort)

if [ ${#wallpapers[@]} -eq 0 ]; then
    notify-send "Error" "No wallpapers found in $WALLPAPERS_DIR for theme $current_theme."
    log "Error: No wallpapers in $WALLPAPERS_DIR."
    exit 1
fi

# Pass basenames to rofi (one per line)
selected_wall=$(printf "%s\n" "${wallpaper_names[@]}" | rofi -dmenu -p "Select Wallpaper for $current_theme")

if [ -z "$selected_wall" ]; then
    exit 0
fi

# Find full path of selected wallpaper (match basename)
full_path=""
for i in "${!wallpaper_names[@]}"; do
    if [[ "${wallpaper_names[$i]}" == "$selected_wall" ]]; then
        full_path="${wallpapers[$i]}"
        break
    fi
done

if [ -z "$full_path" ] || [ ! -f "$full_path" ]; then
    notify-send "Error" "Wallpaper $selected_wall does not exist."
    log "Error: Wallpaper $selected_wall does not exist."
    exit 1
fi

# Apply wallpaper with swww img (with animation)
if swww img "$full_path" $SWWW_ANIMATION_ARGS; then
    log "Success: Set wallpaper to $full_path (with swww animation)."
    echo "$full_path" > "$CURRENT_WALLPAPER_FILE"
else
    notify-send "Error" "Failed to set wallpaper $full_path using swww."
    log "Error: Failed to set wallpaper $full_path using swww."
    exit 1
fi

# Apply colors with pywal
if wal -i "$full_path" -n; then
    log "Success: Applied pywal colors for $full_path."
    # Reload waybar silently
    killall -SIGUSR2 waybar 2>/dev/null
    # Directly update Rofi
    "$UPDATE_ROFI_SCRIPT"
    log "Success: Directly triggered Rofi background update."
else
    notify-send "Error" "Failed to apply pywal colors for $full_path."
    log "Error: Failed to apply pywal colors for $full_path."
    exit 1
fi

notify-send "Wallpaper Changed" "Set wallpaper to $selected_wall (Theme: $current_theme)."
