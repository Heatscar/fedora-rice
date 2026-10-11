#!/usr/bin/env bash
# Tema de apps GTK, iconos y cursor. gsettings es compartido con la sesion de GNOME.

schema=org.gnome.desktop.interface

gsettings set $schema color-scheme 'prefer-dark'
gsettings set $schema gtk-theme 'adw-gtk3-dark'
gsettings set $schema icon-theme 'Papirus-Dark'
gsettings set $schema cursor-theme 'Bibata-Modern-Ice'
gsettings set $schema cursor-size 24

hyprctl setcursor Bibata-Modern-Ice 24
