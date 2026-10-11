#!/usr/bin/env bash
# Muestra la lista de atajos en rofi

rofi -dmenu -i -p "Atajos" -theme-str 'window { width: 720px; } listview { lines: 14; }' < ~/.config/hypr/atajos.txt >/dev/null
