#!/bin/bash

# Get current wallpaper path from pywal cache
WALLPAPER_PATH=$(cat ~/.cache/wal/wal)

# Your Rofi theme file
THEME_FILE="$HOME/.config/rofi/theme.rasi"

# Update background-image
sed -i "s|background-image: url(\".*\", both);|background-image: url(\"$WALLPAPER_PATH\", both);|" "$THEME_FILE"

# No pkill—Rofi won't close, manual reload if needed
# pkill -SIGUSR1 -x rofi || true  # Commented out to prevent auto-close
