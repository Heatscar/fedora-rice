-- Flechas al estilo GNOME sobre el mosaico de Hyprland:
--   izquierda/derecha: si la ventana esta sola en el workspace la ajusta a esa mitad de la
--                      pantalla (flotando); si hay mas ventanas la mueve dentro del mosaico.
--   arriba/abajo:      devuelve al mosaico una ventana ajustada a una mitad; si no, la mueve.
-- Una ventana maximizada o en pantalla completa se restaura antes.

local M = {}

local gap = 12

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
    elseif w.floating then
        hl.dispatch(hl.dsp.window.float({ window = w, action = "disable" }))
    else
        hl.dispatch(hl.dsp.window.move({ window = w, direction = dir }))
    end
end

function M.arrow(dir)
    return function()
        M.apply(hl.get_active_window(), dir)
    end
end

return M
