#!/usr/bin/env bash
# Menu de energia con rofi

lock="$(printf '')  Bloquear"
suspend="$(printf '')  Suspender"
logout="$(printf '')  Cerrar sesión"
reboot="$(printf '')  Reiniciar"
poweroff="$(printf '')  Apagar"

choice="$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$poweroff" |
    rofi -dmenu -i -p "Energía" -theme-str 'window { width: 320px; } listview { lines: 5; }')"

case "$choice" in
    "$lock")     pidof hyprlock || hyprlock ;;
    "$suspend")  systemctl suspend ;;
    "$logout")   hyprctl dispatch 'hl.dsp.exit()' ;;
    "$reboot")   systemctl reboot ;;
    "$poweroff") systemctl poweroff ;;
esac
