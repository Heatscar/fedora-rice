# Prompt starship solo en kitty: sus iconos necesitan una Nerd Font
if [[ $- == *i* && $TERM == xterm-kitty ]] && command -v starship >/dev/null 2>&1; then
    eval "$(starship init bash)"
fi
