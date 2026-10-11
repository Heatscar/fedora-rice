#!/usr/bin/env bash
# Cambia volumen o brillo y muestra un indicador en pantalla (notificacion de mako con barra).
# Uso: osd.sh volume-up|volume-down|volume-mute|mic-mute|brightness-up|brightness-down

show() { # titulo [porcentaje]
    notify-send -a osd -t 1500 -h string:x-canonical-private-synchronous:osd ${2:+-h "int:value:$2"} "$1"
}

volume() { # sink|source icono etiqueta
    local target="@DEFAULT_AUDIO_${1}@" out pct
    out="$(wpctl get-volume "$target")"
    pct="$(awk '{ printf "%d", $2 * 100 + 0.5 }' <<<"$out")"
    if [[ $out == *MUTED* ]]; then
        show "$(printf '')  $3 silenciado" 0
    else
        show "$2  $3 $pct%" "$pct"
    fi
}

case "$1" in
    volume-up)       wpctl set-volume -l 1 @DEFAULT_AUDIO_SINK@ 5%+;   volume SINK "$(printf '')" "Volumen" ;;
    volume-down)     wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-;        volume SINK "$(printf '')" "Volumen" ;;
    volume-mute)     wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle;       volume SINK "$(printf '')" "Volumen" ;;
    mic-mute)        wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle;     volume SOURCE "$(printf '')" "Micrófono" ;;
    brightness-up)   brightnessctl -e4 -n2 set 5%+ >/dev/null ;;&
    brightness-down) brightnessctl -e4 -n2 set 5%- >/dev/null ;;&
    brightness-*)
        pct="$(brightnessctl -e4 -m | cut -d, -f4 | tr -d '%')"
        show "$(printf '')  Brillo $pct%" "$pct"
        ;;
esac
