-- Workspaces fijos segun las pantallas conectadas:
--   portatil + monitor externo: 1-5 en el externo, 6-10 en el portatil
--   solo el portatil:           1-5 en el portatil
-- Son "persistent": existen siempre y aparecen en la barra. Al conectar o desconectar una
-- pantalla se recarga la configuracion para recalcular el reparto.
-- En equipos sin pantalla integrada no hace nada.

local laptop = "eDP-1"

local function screens()
    local has_laptop, external = false, nil
    for _, m in ipairs(hl.get_monitors()) do
        if m.name == laptop then
            has_laptop = true
        elseif not external then
            external = m.name
        end
    end
    return has_laptop, external
end

local has_laptop, external = screens()

local function assign(first, last, monitor)
    for i = first, last do
        hl.workspace_rule({ workspace = tostring(i), monitor = monitor, default = i == first, persistent = true })
    end
end

if has_laptop and external then
    assign(1, 5, external)
    assign(6, 10, laptop)
elseif has_laptop then
    assign(1, 5, laptop)
end

-- Recargar solo si cambio el conjunto de pantallas respecto al de esta carga
local function recheck()
    hl.timer(function()
        local now_laptop, now_external = screens()
        if now_laptop ~= has_laptop or now_external ~= external then
            hl.exec_cmd("hyprctl reload")
        end
    end, { timeout = 500, type = "oneshot" })
end

hl.on("monitor.added", recheck)
hl.on("monitor.removed", recheck)
