-- Pantallas de este equipo. Wiki: https://wiki.hypr.land/Configuring/Basics/Monitors/
-- El instalador no sobrescribe este archivo si ya existe.
-- Para ver los nombres y modos de tus pantallas: hyprctl monitors

-- Por defecto: todas las pantallas en su resolucion nativa, colocadas automaticamente
hl.monitor({
    output   = "",
    mode     = "preferred",
    position = "auto",
    scale    = "auto",
})

-- Ejemplo: monitor externo de 2560x1440 arriba y el portatil (1920x1080 a escala 1.25)
-- centrado debajo. "position" son las coordenadas "XxY" de la esquina superior izquierda
-- de cada pantalla. A escala 1.25 el portatil mide 1536x864, asi que (2560 - 1536) / 2 = 512.
--
-- hl.monitor({
--     output   = "",
--     mode     = "preferred",
--     position = "0x0",
--     scale    = 1,
-- })
--
-- hl.monitor({
--     output   = "eDP-1",
--     mode     = "1920x1080@60",
--     position = "512x1440",
--     scale    = 1.25,
-- })

-- Ejemplo: workspaces fijos por pantalla, 1-5 en el monitor externo y 6-10 en el portatil.
-- "persistent" hace que existan siempre y aparezcan en la barra. El externo se identifica por
-- el principio de su descripcion (ver hyprctl monitors), que no cambia segun el puerto.
--
-- local external = "desc:GGF MG700"
-- for i = 1, 5 do
--     hl.workspace_rule({ workspace = tostring(i), monitor = external, default = i == 1, persistent = true })
-- end
-- for i = 6, 10 do
--     hl.workspace_rule({ workspace = tostring(i), monitor = "eDP-1", default = i == 6, persistent = true })
-- end
