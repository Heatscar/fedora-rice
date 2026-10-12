#!/usr/bin/env bash
# Menu de energia con rofi. Apagar, reiniciar y cerrar sesion piden confirmacion con una
# cuenta atras de 60 segundos, como en GNOME.

lock="$(printf '')  Bloquear"
suspend="$(printf '')  Suspender"
logout="$(printf '')  Cerrar sesión"
reboot="$(printf '')  Reiniciar"
poweroff="$(printf '')  Apagar"

# confirm "Titulo" "El equipo se apagará" "Apagar ahora"
# Devuelve 0 si se acepta o se agota la cuenta atras, 1 si se cancela.
confirm() {
    local title="$1" message="$2" now="$3" seconds=60 out rc
    out="$( (
        for ((i = seconds; i > 0; i--)); do
            echo "# $message en $i segundos"
            echo $(((seconds - i) * 100 / seconds))
            sleep 1
        done
        echo 100
    ) | zenity --progress --title="$title" --text="$message en $seconds segundos" \
            --percentage=0 --auto-close --width=420 \
            --cancel-label="Cancelar" --extra-button="$now"
    )"
    rc=$?
    [ "$rc" -eq 0 ] || [ "$out" = "$now" ]
}

choice="$(printf '%s\n' "$lock" "$suspend" "$logout" "$reboot" "$poweroff" |
    rofi -dmenu -i -p "Energía" -theme-str 'window { width: 320px; } listview { lines: 5; }')"

case "$choice" in
    "$lock")     pidof hyprlock || hyprlock ;;
    "$suspend")
        # Esperar a que este menu termine de cerrarse; si no, su ultimo fotograma reaparece al
        # despertar. No bloquear aqui: lo hace hypridle (before_sleep_cmd) cuando el sistema ya
        # se esta durmiendo, y asi hyprlock no activa el lector de huella hasta despertar.
        # Si el lector queda activo justo antes de dormir, la huella falla al volver.
        sleep 0.4
        systemctl suspend
        ;;
    "$logout")   confirm "Cerrar sesión" "La sesión se cerrará" "Cerrar sesión ahora" && hyprctl dispatch 'hl.dsp.exit()' ;;
    "$reboot")   confirm "Reiniciar" "El equipo se reiniciará" "Reiniciar ahora" && systemctl reboot ;;
    "$poweroff") confirm "Apagar" "El equipo se apagará" "Apagar ahora" && systemctl poweroff ;;
esac
