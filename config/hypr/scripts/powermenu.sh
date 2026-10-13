#!/usr/bin/env bash
# Menu de energia con rofi. Apagar, reiniciar y cerrar sesion piden confirmacion con una
# cuenta atras de 60 segundos, como en GNOME.

lock="$(printf '')  Bloquear"
suspend="$(printf '')  Suspender"
logout="$(printf '')  Cerrar sesión"
reboot="$(printf '')  Reiniciar"
poweroff="$(printf '')  Apagar"

# confirm "Titulo" "El equipo se apagará" "Apagar ahora"
# Devuelve 0 si se pulsa el boton de accion o se agota la cuenta atras, 1 si se cancela.
confirm() {
    local title="$1" message="$2" now="$3" seconds=60 fifo feeder out rc

    # La cuenta atras alimenta a zenity por una tuberia con nombre y se mata en cuanto zenity
    # cierra. Con una tuberia normal ("bucle | zenity") el script esperaria al bucle entero:
    # los programas lanzados por Hyprland ignoran SIGPIPE, asi que el bucle no muere al cerrarse
    # el dialogo y el boton no tendria efecto hasta agotarse los 60 segundos.
    fifo="$(mktemp -u "${XDG_RUNTIME_DIR:-/tmp}/powermenu.XXXXXX")"
    mkfifo "$fifo" || return 1
    (
        for ((i = seconds; i > 0; i--)); do
            echo "# $message en $i segundos"
            echo $(((seconds - i) * 100 / seconds))
            sleep 1
        done
        echo 100
    ) >"$fifo" 2>/dev/null &
    feeder=$!

    out="$(zenity --progress --title="$title" --text="$message en $seconds segundos" \
        --percentage=0 --auto-close --width=420 \
        --cancel-label="Cancelar" --extra-button="$now" <"$fifo")"
    rc=$?

    pkill -P "$feeder" 2>/dev/null
    kill "$feeder" 2>/dev/null
    rm -f "$fifo"

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
