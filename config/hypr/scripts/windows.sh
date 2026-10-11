#!/usr/bin/env bash
# Alt + Tab: lista de todas las ventanas abiertas. Alt + Tab o las flechas avanzan, Enter elige.

pidof rofi >/dev/null && exit 0

rofi -show window -selected-row 1 \
    -window-format '{t}' \
    -kb-row-down 'Alt+Tab,Down,Control+n' \
    -kb-row-up 'Alt+ISO_Left_Tab,Up,Control+p' \
    -kb-accept-entry 'Return,KP_Enter' \
    -kb-cancel 'Alt+Escape,Escape' \
    -theme-str 'window { width: 760px; }'
