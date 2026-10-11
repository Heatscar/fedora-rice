#!/usr/bin/env bash
# Uso: screenshot.sh region|full  -> guarda en Pictures/Screenshots y copia al portapapeles

dir="$(xdg-user-dir PICTURES)/Screenshots"
mkdir -p "$dir"
file="$dir/$(date +%Y-%m-%d_%H-%M-%S).png"

case "$1" in
    region)
        area="$(slurp)" || exit 0
        grim -g "$area" "$file"
        ;;
    *)
        grim "$file"
        ;;
esac

[ -f "$file" ] || exit 1
wl-copy < "$file"
notify-send -i "$file" "Captura guardada" "$file"
