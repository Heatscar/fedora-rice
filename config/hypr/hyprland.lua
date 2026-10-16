-- Hyprland 0.56 (config en Lua) - rice Tokyo Night
-- Wiki: https://wiki.hypr.land/Configuring/Start/

local home    = os.getenv("HOME")
local scripts = home .. "/.config/hypr/scripts/"

------------------
---- MONITORS ----
------------------

-- La disposicion de pantallas es propia de cada equipo y vive en monitors.lua
require("monitors")
require("workspaces")   -- reparto de workspaces segun las pantallas conectadas


------------------
---- PROGRAMS ----
------------------

local terminal    = "kitty"
local fileManager = "nautilus"
local browser     = "firefox"
local menu        = "pkill -x rofi || rofi -show drun"   -- abre el lanzador, o lo cierra si ya esta abierto


-------------------
---- AUTOSTART ----
-------------------

hl.on("hyprland.start", function()
    hl.exec_cmd(scripts .. "theme.sh")
    hl.exec_cmd("hyprpaper")
    hl.exec_cmd("waybar")
    hl.exec_cmd("mako")
    hl.exec_cmd("hypridle")
    hl.exec_cmd("hyprsunset")
    hl.exec_cmd("systemctl --user start hyprpolkitagent")
    hl.exec_cmd("nm-applet --indicator")
    -- Bluetooth apagado al iniciar sesion; se enciende a mano desde el icono de la bandeja.
    -- Bloquear por rfkill corta la radio: apagarlo solo desde bluez no basta, porque el
    -- adaptador se reinicia y bluez lo vuelve a encender solo.
    hl.exec_cmd("rfkill block bluetooth")
    hl.exec_cmd("blueman-applet")
    hl.exec_cmd("wl-paste --type text --watch cliphist store")
    hl.exec_cmd("wl-paste --type image --watch cliphist store")
end)


-------------------------------
---- ENVIRONMENT VARIABLES ----
-------------------------------

hl.env("XCURSOR_THEME", "Bibata-Modern-Ice")
hl.env("XCURSOR_SIZE", "24")
hl.env("HYPRCURSOR_SIZE", "24")


-----------------------
---- LOOK AND FEEL ----
-----------------------

-- Paleta Tokyo Night
local blue    = "rgba(7aa2f7ee)"
local magenta = "rgba(bb9af7ee)"
local muted   = "rgba(414868aa)"

hl.config({
    general = {
        gaps_in  = 5,
        gaps_out = 12,

        border_size = 2,

        col = {
            active_border   = { colors = { blue, magenta }, angle = 45 },
            inactive_border = muted,
        },

        resize_on_border = true,
        allow_tearing    = false,

        layout = "dwindle",
    },

    decoration = {
        rounding       = 12,
        rounding_power = 2,

        active_opacity   = 1.0,
        inactive_opacity = 0.95,

        shadow = {
            enabled      = true,
            range        = 16,
            render_power = 3,
            color        = 0x9916161e,
        },

        blur = {
            enabled  = true,
            size     = 6,
            passes   = 2,
            vibrancy = 0.17,
        },
    },

    animations = {
        enabled = true,
    },
})

hl.curve("easeOutQuint",   { type = "bezier", points = { {0.23, 1},    {0.32, 1}    } })
hl.curve("easeInOutCubic", { type = "bezier", points = { {0.65, 0.05}, {0.36, 1}    } })
hl.curve("linear",         { type = "bezier", points = { {0, 0},       {1, 1}       } })
hl.curve("almostLinear",   { type = "bezier", points = { {0.5, 0.5},   {0.75, 1}    } })
hl.curve("quick",          { type = "bezier", points = { {0.15, 0},    {0.1, 1}     } })

hl.curve("easy",           { type = "spring", mass = 1, stiffness = 238.1191, dampening = 24.21279333 })

hl.animation({ leaf = "global",        enabled = true,  speed = 10,   bezier = "default" })
hl.animation({ leaf = "border",        enabled = true,  speed = 5.39, bezier = "easeOutQuint" })
hl.animation({ leaf = "windows",       enabled = true,  speed = 4.79, spring = "easy" })
hl.animation({ leaf = "windowsIn",     enabled = true,  speed = 4.1,  spring = "easy",         style = "popin 87%" })
hl.animation({ leaf = "windowsOut",    enabled = true,  speed = 1.49, bezier = "linear",       style = "popin 87%" })
hl.animation({ leaf = "fadeIn",        enabled = true,  speed = 1.73, bezier = "almostLinear" })
hl.animation({ leaf = "fadeOut",       enabled = true,  speed = 1.46, bezier = "almostLinear" })
hl.animation({ leaf = "fade",          enabled = true,  speed = 3.03, bezier = "quick" })
hl.animation({ leaf = "layers",        enabled = true,  speed = 3.81, bezier = "easeOutQuint" })
hl.animation({ leaf = "layersIn",      enabled = true,  speed = 4,    bezier = "easeOutQuint", style = "fade" })
hl.animation({ leaf = "layersOut",     enabled = true,  speed = 1.5,  bezier = "linear",       style = "fade" })
hl.animation({ leaf = "fadeLayersIn",  enabled = true,  speed = 1.79, bezier = "almostLinear" })
hl.animation({ leaf = "fadeLayersOut", enabled = true,  speed = 1.39, bezier = "almostLinear" })
hl.animation({ leaf = "workspaces",    enabled = true,  speed = 3.5,  bezier = "easeOutQuint", style = "slide" })
hl.animation({ leaf = "zoomFactor",    enabled = true,  speed = 7,    bezier = "quick" })

hl.config({
    dwindle = {
        preserve_split = true,
    },
})

hl.config({
    master = {
        new_status = "master",
    },
})

----------------
----  MISC  ----
----------------

hl.config({
    misc = {
        force_default_wallpaper = 0,
        disable_hyprland_logo   = true,
    },
})


---------------
---- INPUT ----
---------------

hl.config({
    input = {
        -- SUPER + SHIFT + Espacio alterna entre us y latam (bind mas abajo)
        kb_layout  = "us,latam",
        kb_variant = "",
        kb_model   = "",
        kb_options = "",
        kb_rules   = "",

        follow_mouse = 1,

        sensitivity = 0,

        touchpad = {
            natural_scroll = false,   -- true = el contenido sigue a los dedos (estilo macOS)
            tap_to_click   = true,
        },
    },
})

hl.gesture({
    fingers = 3,
    direction = "horizontal",
    action = "workspace"
})


---------------------
---- KEYBINDINGS ----
---------------------

local mainMod = "SUPER"

-- Programas
hl.bind(mainMod .. " + Return", hl.dsp.exec_cmd(terminal))
hl.bind(mainMod .. " + space",  hl.dsp.exec_cmd(menu))
hl.bind(mainMod .. " + E",      hl.dsp.exec_cmd(fileManager))
hl.bind(mainMod .. " + B",      hl.dsp.exec_cmd(browser))

-- Sesion
hl.bind(mainMod .. " + L",         hl.dsp.exec_cmd("pidof hyprlock || hyprlock"))
hl.bind(mainMod .. " + SHIFT + E", hl.dsp.exec_cmd(scripts .. "powermenu.sh"))
hl.bind("CTRL + ALT + Delete",     hl.dsp.exec_cmd(scripts .. "powermenu.sh"))
hl.bind(mainMod .. " + V",         hl.dsp.exec_cmd(scripts .. "clipboard.sh"))
hl.bind(mainMod .. " + N",         hl.dsp.exec_cmd(scripts .. "nightlight.sh"))
hl.bind(mainMod .. " + SHIFT + space", hl.dsp.exec_cmd("hyprctl switchxkblayout all next"))
hl.bind(mainMod .. " + F1",        hl.dsp.exec_cmd(scripts .. "atajos.sh"))
-- Ajustes de GNOME: sirven para red, sonido y energia. Bluetooth, pantallas y apariencia no: dependen
-- de servicios de la sesion de GNOME (el Bluetooth se gestiona con blueman, en la bandeja)
hl.bind(mainMod .. " + I",         hl.dsp.exec_cmd("env XDG_CURRENT_DESKTOP=GNOME gnome-control-center"))

-- Ventanas
hl.bind(mainMod .. " + Q", hl.dsp.window.close())
hl.bind(mainMod .. " + SHIFT + V", hl.dsp.window.float({ action = "toggle" }))
hl.bind(mainMod .. " + F", require("fullscreen").bind())      -- ver fullscreen.lua
hl.bind(mainMod .. " + M", hl.dsp.window.fullscreen({ mode = "maximized" }))
hl.bind(mainMod .. " + J", hl.dsp.layout("togglesplit"))    -- dwindle only

-- Flechas: mover/ajustar la ventana (ver snap.lua), con SHIFT enviarla a la otra pantalla,
-- con ALT cambiar el foco
local snap = require("snap")
local monitorDir = { left = "l", right = "r", up = "u", down = "d" }
for _, dir in ipairs({ "left", "right", "up", "down" }) do
    hl.bind(mainMod .. " + " .. dir,         snap.arrow(dir))
    hl.bind(mainMod .. " + SHIFT + " .. dir, hl.dsp.window.move({ monitor = monitorDir[dir] }))
    hl.bind(mainMod .. " + ALT + " .. dir,   hl.dsp.focus({ direction = dir }))
end
-- Lista de todas las ventanas. non_consuming deja pasar Alt + Tab a rofi para avanzar en la lista
hl.bind("ALT + Tab", hl.dsp.exec_cmd(scripts .. "windows.sh"), { non_consuming = true })

hl.bind(mainMod .. " + CTRL + left",  hl.dsp.window.resize({ x = -40, y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + right", hl.dsp.window.resize({ x = 40,  y = 0,   relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + up",    hl.dsp.window.resize({ x = 0,   y = -40, relative = true }), { repeating = true })
hl.bind(mainMod .. " + CTRL + down",  hl.dsp.window.resize({ x = 0,   y = 40,  relative = true }), { repeating = true })

-- Workspaces: mainMod + [0-9], y con SHIFT se mueve la ventana activa
for i = 1, 10 do
    local key = i % 10 -- 10 maps to key 0
    hl.bind(mainMod .. " + " .. key,             hl.dsp.focus({ workspace = i}))
    hl.bind(mainMod .. " + SHIFT + " .. key,     hl.dsp.window.move({ workspace = i }))
end

-- Enviar la ventana activa al primer workspace vacio de esta pantalla (y seguirla)
hl.bind(mainMod .. " + SHIFT + N", hl.dsp.window.move({ workspace = "emptym" }))

-- Volver al workspace anterior
hl.bind(mainMod .. " + Tab", hl.dsp.focus({ workspace = "previous" }))

hl.bind(mainMod .. " + mouse_down", hl.dsp.focus({ workspace = "e+1" }))
hl.bind(mainMod .. " + mouse_up",   hl.dsp.focus({ workspace = "e-1" }))

hl.bind(mainMod .. " + mouse:272", hl.dsp.window.drag(),   { mouse = true })
hl.bind(mainMod .. " + mouse:273", hl.dsp.window.resize(), { mouse = true })

-- Capturas: region / pantalla completa
hl.bind("Print",         hl.dsp.exec_cmd(scripts .. "screenshot.sh region"))
hl.bind("SHIFT + Print", hl.dsp.exec_cmd(scripts .. "screenshot.sh full"))
hl.bind(mainMod .. " + SHIFT + S", hl.dsp.exec_cmd(scripts .. "screenshot.sh region"))

-- Teclas multimedia
-- osd.sh cambia el valor y muestra el indicador en pantalla
hl.bind("XF86AudioRaiseVolume",  hl.dsp.exec_cmd(scripts .. "osd.sh volume-up"),       { locked = true, repeating = true })
hl.bind("XF86AudioLowerVolume",  hl.dsp.exec_cmd(scripts .. "osd.sh volume-down"),     { locked = true, repeating = true })
hl.bind("XF86AudioMute",         hl.dsp.exec_cmd(scripts .. "osd.sh volume-mute"),     { locked = true })
hl.bind("XF86AudioMicMute",      hl.dsp.exec_cmd(scripts .. "osd.sh mic-mute"),        { locked = true })
hl.bind("XF86MonBrightnessUp",   hl.dsp.exec_cmd(scripts .. "osd.sh brightness-up"),   { locked = true, repeating = true })
hl.bind("XF86MonBrightnessDown", hl.dsp.exec_cmd(scripts .. "osd.sh brightness-down"), { locked = true, repeating = true })

hl.bind("XF86AudioNext",  hl.dsp.exec_cmd("playerctl next"),       { locked = true })
hl.bind("XF86AudioPause", hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPlay",  hl.dsp.exec_cmd("playerctl play-pause"), { locked = true })
hl.bind("XF86AudioPrev",  hl.dsp.exec_cmd("playerctl previous"),   { locked = true })


--------------------------------
---- WINDOWS AND WORKSPACES ----
--------------------------------

hl.window_rule({
    name  = "suppress-maximize-events",
    match = { class = ".*" },

    suppress_event = "maximize",
})

hl.window_rule({
    -- Fix some dragging issues with XWayland
    name  = "fix-xwayland-drags",
    match = {
        class      = "^$",
        title      = "^$",
        xwayland   = true,
        float      = true,
        fullscreen = false,
        pin        = false,
    },

    no_focus = true,
})

hl.window_rule({
    name  = "float-utilities",
    match = { class = "^(org.pulseaudio.pavucontrol|blueman-manager|nm-connection-editor|org.gnome.Calculator)$" },

    float  = true,
    center = true,
    size   = { 900, 600 },
})

hl.window_rule({
    name  = "float-file-dialogs",
    match = { title = "^(Open File|Open Folder|Save File|Save As|Abrir archivo|Guardar como).*" },

    float  = true,
    center = true,
})

-- Blur detras de la barra, el lanzador y las notificaciones
hl.layer_rule({ name = "blur-waybar", match = { namespace = "^waybar$" },        blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-rofi",   match = { namespace = "^rofi$" },          blur = true, ignore_alpha = 0.2 })
hl.layer_rule({ name = "blur-mako",   match = { namespace = "^notifications$" }, blur = true, ignore_alpha = 0.2 })
