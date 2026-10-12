#!/usr/bin/env bash
# Campanita de notificaciones de la barra (historial de mako).
# Uso: notifications.sh status | menu | dnd
#   status  JSON para waybar: numero de notificaciones sin ver y estado de "no molestar"
#   menu    lista del historial en rofi; Enter copia el texto de la elegida
#   dnd     alterna "no molestar"

seen_file="${XDG_RUNTIME_DIR:-/tmp}/notifications-seen"
bell="$(printf '')"
bell_off="$(printf '')"

all() { { makoctl list -j; makoctl history -j; } 2>/dev/null | jq -s 'add // [] | sort_by(-.id)'; }
is_dnd() { makoctl mode 2>/dev/null | grep -qx 'do-not-disturb'; }
refresh() { pkill -RTMIN+8 -x waybar; }

case "$1" in
    status)
        seen="$(cat "$seen_file" 2>/dev/null || echo 0)"
        unread="$(all | jq --argjson seen "$seen" '[.[] | select(.id > $seen)] | length')"
        if is_dnd; then
            jq -cn --arg t "$bell_off" '{text: $t, class: "dnd", tooltip: "No molestar activado\nClic derecho para desactivarlo"}'
        elif [ "${unread:-0}" -gt 0 ]; then
            jq -cn --arg t "$bell  $unread" --arg n "$unread" '{text: $t, class: "unread", tooltip: ($n + " sin ver\nClic: historial · Clic derecho: no molestar")}'
        else
            jq -cn --arg t "$bell" '{text: $t, class: "empty", tooltip: "Sin notificaciones nuevas\nClic: historial · Clic derecho: no molestar"}'
        fi
        ;;

    menu)
        items="$(all)"
        echo "$(jq '.[0].id // 0' <<<"$items")" >"$seen_file"
        refresh

        if is_dnd; then dnd_label="$bell  Desactivar no molestar"; else dnd_label="$bell_off  Activar no molestar"; fi
        clear_label="$(printf '')  Borrar historial"

        # Una linea por notificacion: sin etiquetas de formato ni saltos de linea
        lines="$(jq -r '.[] | "\(.app_name // "")  ·  \(.summary // "")\(if (.body // "") != "" then " — " + .body else "" end)"
                        | gsub("<[^>]*>"; "") | gsub("\\s+"; " ") | .[0:160]' <<<"$items")"

        choice="$(printf '%s\n' "$dnd_label" "$clear_label" "$lines" | sed '/^$/d' |
            rofi -dmenu -i -p "Notificaciones" -format i -theme-str 'window { width: 820px; } listview { lines: 12; }')"
        [ -n "$choice" ] || exit 0

        case "$choice" in
            0) "$0" dnd ;;
            1)
                # mako no tiene orden para vaciar el historial: se reinicia
                pkill -x mako
                hyprctl dispatch 'hl.dsp.exec_cmd("mako")' >/dev/null
                echo 0 >"$seen_file"
                sleep 0.5
                refresh
                ;;
            *)
                jq -r --argjson i "$((choice - 2))" '.[$i] | "\(.summary // "")\n\(.body // "")" | gsub("<[^>]*>"; "")' <<<"$items" | wl-copy
                ;;
        esac
        ;;

    dnd)
        makoctl mode -t do-not-disturb >/dev/null
        refresh
        ;;
esac
