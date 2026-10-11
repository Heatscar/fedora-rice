#!/usr/bin/env bash
# Uso: wallpaper.sh /ruta/a/imagen  -> cambia el fondo del escritorio y el del bloqueo

src="$1"
[ -f "$src" ] || { echo "Uso: wallpaper.sh /ruta/a/imagen"; exit 1; }

case "$(file -b --mime-type "$src")" in
    image/jpeg) ext=jpg ;;
    image/png)  ext=png ;;
    image/webp) ext=webp ;;
    image/jxl)  ext=jxl ;;
    *) echo "Formato no soportado (usa jpg, png, webp o jxl)"; exit 1 ;;
esac

dir="$HOME/.config/hypr"
dest="$dir/fondo.$ext"
rm -f "$dir"/fondo.*
cp "$src" "$dest"

sed -i "s|^\( *path = \).*|\1$dest|" "$dir/hyprpaper.conf" "$dir/hyprlock.conf"
hyprctl hyprpaper wallpaper ", $dest" >/dev/null 2>&1 || true
for mon in $(hyprctl monitors -j | jq -r '.[].name'); do
    hyprctl hyprpaper wallpaper "$mon, $dest" >/dev/null 2>&1 || true
done
echo "Fondo: $dest"
