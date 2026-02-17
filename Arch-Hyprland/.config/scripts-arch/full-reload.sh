#!/bin/bash
# Reload Hyprland core
hyprctl reload

# Restart Waybar (with SIGUSR1 to avoid flicker)
killall waybar || true
waybar &

# Restart Rofi/Wofi
killall rofi || true
killall wofi || true


# Gracefully reload Alacritty (if using Pywal)
#killall -USR1 alacritty 2>/dev/null


# Restart notifications (dunst)
killall dunst && dunst &

# Optional: Restart other apps (e.g., network applet)
killall nm-applet && nm-applet &

