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
