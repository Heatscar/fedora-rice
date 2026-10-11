#!/usr/bin/env bash
# Instalador del rice Hyprland + Tokyo Night para Fedora.
#
# Uso:
#   ./install.sh                 instala paquetes, fuente, cursor, starship y configuraciones
#   ./install.sh --no-packages   omite dnf (no pide sudo)
#   ./install.sh --configs-only  solo copia las configuraciones
set -euo pipefail

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/.config"
BACKUP_DIR="$CONFIG_DIR/rice-backup-$(date +%Y%m%d-%H%M%S)"

COPR_REPO="sdegler/hyprland"
PACKAGES=(
    # Hyprland y su ecosistema (COPR)
    hyprland hyprpaper hyprlock hypridle hyprpolkitagent xdg-desktop-portal-hyprland
    # Barra, lanzador, terminal y notificaciones
    waybar rofi kitty mako
    # Utilidades que usan los atajos y scripts
    grim slurp cliphist wl-clipboard brightnessctl playerctl jq libnotify xdg-user-dirs file
    # Applets de sonido, red y bluetooth
    pavucontrol network-manager-applet blueman
    # Temas
    papirus-icon-theme adw-gtk3-theme
)

FONT_URL="https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.tar.xz"
CURSOR_URL="https://github.com/ful1e5/Bibata_Cursor/releases/latest/download/Bibata-Modern-Ice.tar.xz"
STARSHIP_URL="https://github.com/starship/starship/releases/latest/download/starship-x86_64-unknown-linux-gnu.tar.gz"

do_packages=true
do_extras=true

for arg in "$@"; do
    case "$arg" in
        --no-packages)  do_packages=false ;;
        --configs-only) do_packages=false; do_extras=false ;;
        -h|--help)      sed -n '2,7p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
        *)              echo "Opción desconocida: $arg"; exit 1 ;;
    esac
done

info() { printf '\n\033[1;34m==>\033[0m %s\n' "$1"; }
warn() { printf '\033[1;33mAviso:\033[0m %s\n' "$1"; }

install_packages() {
    info "Activando el COPR $COPR_REPO e instalando paquetes (pide sudo)"
    if ! grep -qi '^ID=fedora' /etc/os-release; then
        warn "Esto no parece Fedora; los nombres de paquetes pueden no coincidir."
    fi
    sudo dnf copr enable "$COPR_REPO"
    sudo dnf install "${PACKAGES[@]}"
}

install_font() {
    local dest="$HOME/.local/share/fonts/JetBrainsMonoNerd"
    if [ -d "$dest" ]; then
        info "Fuente JetBrainsMono Nerd Font: ya instalada"
        return
    fi
    info "Instalando la fuente JetBrainsMono Nerd Font"
    local tmp; tmp="$(mktemp -d)"
    curl -fL --progress-bar -o "$tmp/font.tar.xz" "$FONT_URL"
    mkdir -p "$dest"
    tar -xf "$tmp/font.tar.xz" -C "$dest" --wildcards '*.ttf'
    rm -rf "$tmp"
    fc-cache -f "$HOME/.local/share/fonts" >/dev/null 2>&1 || true
}

install_cursor() {
    local dest="$HOME/.local/share/icons"
    if [ -d "$dest/Bibata-Modern-Ice" ]; then
        info "Cursor Bibata-Modern-Ice: ya instalado"
        return
    fi
    info "Instalando el cursor Bibata-Modern-Ice"
    local tmp; tmp="$(mktemp -d)"
    curl -fL --progress-bar -o "$tmp/cursor.tar.xz" "$CURSOR_URL"
    mkdir -p "$dest"
    tar -xf "$tmp/cursor.tar.xz" -C "$dest"
    rm -rf "$tmp"
}

install_starship() {
    if command -v starship >/dev/null 2>&1 || [ -x "$HOME/.local/bin/starship" ]; then
        info "Starship: ya instalado"
        return
    fi
    if [ "$(uname -m)" != "x86_64" ]; then
        warn "Starship: descarga automática solo para x86_64; instálalo desde https://starship.rs"
        return
    fi
    info "Instalando starship en ~/.local/bin"
    local tmp; tmp="$(mktemp -d)"
    curl -fL --progress-bar -o "$tmp/starship.tar.gz" "$STARSHIP_URL"
    curl -fsSL -o "$tmp/starship.sha256" "$STARSHIP_URL.sha256"
    if [ "$(sha256sum "$tmp/starship.tar.gz" | cut -d' ' -f1)" != "$(tr -d '[:space:]' < "$tmp/starship.sha256")" ]; then
        rm -rf "$tmp"
        echo "La suma sha256 de starship no coincide; no se instala."
        exit 1
    fi
    mkdir -p "$HOME/.local/bin"
    tar -xzf "$tmp/starship.tar.gz" -C "$HOME/.local/bin" starship
    chmod +x "$HOME/.local/bin/starship"
    rm -rf "$tmp"
}

# Copia un archivo; si el destino existe y es distinto, guarda antes una copia en BACKUP_DIR
copy_file() {
    local src="$1" dest="$2" rel="$3"
    if [ -e "$dest" ] && ! cmp -s "$src" "$dest"; then
        mkdir -p "$BACKUP_DIR/$(dirname "$rel")"
        cp -a "$dest" "$BACKUP_DIR/$rel"
    fi
    mkdir -p "$(dirname "$dest")"
    cp -a "$src" "$dest"
}

install_configs() {
    info "Copiando configuraciones a $CONFIG_DIR"
    local src rel
    while IFS= read -r -d '' src; do
        rel="${src#"$REPO_DIR/config/"}"
        # La disposicion de pantallas es de cada equipo: no se pisa si ya existe
        if [ "$rel" = "hypr/monitors.lua" ] && [ -e "$CONFIG_DIR/$rel" ]; then
            continue
        fi
        copy_file "$src" "$CONFIG_DIR/$rel" "$rel"
    done < <(find "$REPO_DIR/config" -type f -print0)

    copy_file "$REPO_DIR/bashrc.d/starship.sh" "$HOME/.bashrc.d/starship.sh" "bashrc.d/starship.sh"
    chmod +x "$CONFIG_DIR"/hypr/scripts/*.sh

    if ! grep -q 'bashrc\.d' "$HOME/.bashrc" 2>/dev/null; then
        warn "Tu ~/.bashrc no carga ~/.bashrc.d; añade esta línea para activar el prompt:"
        echo '    for rc in ~/.bashrc.d/*; do [ -f "$rc" ] && . "$rc"; done'
    fi
    if [ -d "$BACKUP_DIR" ]; then
        echo "Tus archivos anteriores quedaron en $BACKUP_DIR"
    fi
}

$do_packages && install_packages
if $do_extras; then
    install_font
    install_cursor
    install_starship
fi
install_configs

info "Listo"
echo "Cierra sesión y elige \"Hyprland\" en el engranaje de la pantalla de login."
echo "Dentro de Hyprland, Super + F1 muestra la lista de atajos."
