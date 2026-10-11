#!/usr/bin/env bash
# Historial del portapapeles con cliphist + rofi

cliphist list | rofi -dmenu -i -p "Portapapeles" -display-columns 2 | cliphist decode | wl-copy
