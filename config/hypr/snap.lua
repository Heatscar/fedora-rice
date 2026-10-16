-- Flechas al estilo GNOME sobre el mosaico de Hyprland:
--   izquierda/derecha: si la ventana esta sola en el workspace la ajusta a esa mitad de la
--                      pantalla (flotando); si hay mas ventanas la mueve dentro del mosaico.
--   arriba/abajo:      devuelve al mosaico una ventana ajustada a una mitad; si no, la mueve.
-- Una ventana maximizada o en pantalla completa se restaura antes.
--
-- Si se abre otra ventana en un workspace con una ventana ajustada, la ajustada vuelve al
-- mosaico conservando su lado y la nueva ocupa la otra mitad, en vez de quedar debajo.

local M = {}

local gap = 12

-- direccion de la ventana ajustada -> "left" | "right"
local snapped = {}

local function place_half(w, dir)
    local m = w.monitor
    local r = m.reserved
    local x0 = m.x + r.left + gap
    local y0 = m.y + r.top + gap
    local uw = m.width / m.scale - r.left - r.right - 2 * gap
    local uh = m.height / m.scale - r.top - r.bottom - 2 * gap
    local hw = math.floor((uw - gap) / 2)
    local x  = dir == "left" and x0 or x0 + uw - hw

    hl.dispatch(hl.dsp.window.resize({ window = w, x = hw, y = math.floor(uh), relative = false }))
    hl.dispatch(hl.dsp.window.move({ window = w, x = math.floor(x), y = math.floor(y0), relative = false }))
end

function M.apply(w, dir)
    if not w or not w.monitor or not w.workspace then return end

    if w.fullscreen ~= 0 then
        local mode = w.fullscreen == 1 and "maximized" or "fullscreen"
        hl.dispatch(hl.dsp.window.fullscreen({ window = w, mode = mode, action = "unset" }))
    end

    local horizontal = dir == "left" or dir == "right"

    if horizontal and (w.floating or w.workspace.windows == 1) then
        if not w.floating then
            hl.dispatch(hl.dsp.window.float({ window = w, action = "enable" }))
        end
        place_half(w, dir)
        snapped[w.address] = dir
    elseif w.floating then
        hl.dispatch(hl.dsp.window.float({ window = w, action = "disable" }))
        snapped[w.address] = nil
    else
        hl.dispatch(hl.dsp.window.move({ window = w, direction = dir }))
    end
end

function M.arrow(dir)
    return function()
        M.apply(hl.get_active_window(), dir)
    end
end

-- Devuelve al mosaico la ventana ajustada del workspace de "new" y la deja en su lado
local function retile_for(new)
    if not new or not new.workspace or new.floating then return end

    for address, side in pairs(snapped) do
        local s = hl.get_window("address:" .. address)
        if not s or not s.mapped or not s.floating then
            snapped[address] = nil
        elseif s.workspace and s.workspace.id == new.workspace.id and s.address ~= new.address then
            snapped[address] = nil
            hl.dispatch(hl.dsp.window.float({ window = s, action = "disable" }))

            -- El mosaico decide el lado al dividir; si quedo al reves, intercambiarlas
            hl.timer(function()
                local a, b = hl.get_window("address:" .. address), hl.get_window("address:" .. new.address)
                if not a or not b then return end
                local wrong = (side == "left" and a.at.x > b.at.x) or (side == "right" and a.at.x < b.at.x)
                if wrong then
                    hl.dispatch(hl.dsp.window.swap({ window = b, target = a }))
                end
            end, { timeout = 80, type = "oneshot" })
            return
        end
    end
end

hl.on("window.open", function(w)
    -- Esperar a que la ventana nueva tenga su sitio en el mosaico
    hl.timer(function() retile_for(w and hl.get_window("address:" .. w.address)) end,
        { timeout = 50, type = "oneshot" })
end)

hl.on("window.close", function(w)
    if w then snapped[w.address] = nil end
end)

return M
