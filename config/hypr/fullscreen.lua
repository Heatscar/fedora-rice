-- Pantalla completa al estilo macOS: si la ventana comparte workspace con otras, se lleva
-- a un workspace vacio de la misma pantalla antes de ponerla en pantalla completa, y al salir vuelve al de origen.

local M = {}

-- direccion de la ventana -> id del workspace del que salio
local origins = {}

function M.toggle(w)
    if not w or not w.workspace then return end

    if w.fullscreen == 2 then
        hl.dispatch(hl.dsp.window.fullscreen({ window = w, mode = "fullscreen", action = "unset" }))
        local origin = origins[w.address]
        origins[w.address] = nil
        if origin and w.workspace.windows == 1 then
            hl.dispatch(hl.dsp.window.move({ window = w, workspace = origin }))
        end
        return
    end

    if w.fullscreen ~= 0 then
        hl.dispatch(hl.dsp.window.fullscreen({ window = w, mode = "maximized", action = "unset" }))
    end
    if w.workspace.windows > 1 and not w.workspace.special then
        origins[w.address] = w.workspace.id
        hl.dispatch(hl.dsp.window.move({ window = w, workspace = "emptym" }))
    end
    hl.dispatch(hl.dsp.window.fullscreen({ window = w, mode = "fullscreen", action = "set" }))
end

function M.bind()
    return function()
        M.toggle(hl.get_active_window())
    end
end

-- Si se cierra una ventana que estaba en su propio workspace, volver al de origen
hl.on("window.close", function(w)
    if not w then return end
    local origin = origins[w.address]
    if not origin then return end
    origins[w.address] = nil
    if w.fullscreen == 2 then
        hl.dispatch(hl.dsp.focus({ workspace = origin }))
    end
end)

return M
