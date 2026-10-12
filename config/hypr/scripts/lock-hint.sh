#!/usr/bin/env bash
# Texto de ayuda de la pantalla de bloqueo cuando NO hay lector de huella con huellas
# registradas. Si lo hay, no escribe nada: ese texto lo pone hyprlock ($FPRINTPROMPT).

if command -v fprintd-list >/dev/null 2>&1 && fprintd-list "$USER" 2>/dev/null | grep -q '#[0-9]'; then
    exit 0
fi
echo "Escribe tu contraseña"
