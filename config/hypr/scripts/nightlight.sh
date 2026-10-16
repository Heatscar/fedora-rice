#!/usr/bin/env bash
# Alterna la luz nocturna a mano. El horario automatico esta en hyprsunset.conf.

warm=3500
state_file="${XDG_RUNTIME_DIR:-/tmp}/nightlight-state"

osd() { notify-send -a osd -t 1500 -h string:x-canonical-private-synchronous:osd "$1" ${2:+"$2"}; }

if ! pidof hyprsunset >/dev/null; then
    osd "Luz nocturna no disponible" "Instala hyprsunset"
    exit 1
fi

# Perfil horario vigente: su hora identifica el tramo y su temperatura dice si es calido
profile="$(hyprctl hyprsunset profile 2>/dev/null)"
slot="$(awk '/^Time:/ { print $2 }' <<<"$profile")"
temp="$(awk '/^Temperature:/ { print $2 }' <<<"$profile")"
[ "${temp:-6000}" -lt 6000 ] && current=on || current=off

# Un cambio manual solo cuenta mientras dure el tramo horario en que se hizo
if read -r saved saved_slot 2>/dev/null <"$state_file" && [ "$saved_slot" = "$slot" ]; then
    current="$saved"
fi

if [ "$current" = on ]; then
    hyprctl hyprsunset identity >/dev/null
    echo "off $slot" >"$state_file"
    osd "$(printf '')  Luz nocturna desactivada"
else
    hyprctl hyprsunset temperature "$warm" >/dev/null
    echo "on $slot" >"$state_file"
    osd "$(printf '')  Luz nocturna activada"
fi
