
local Eventos = {}

Eventos.suscriptores = {}

function Eventos.Suscribir(nombre, funcion)
    if Eventos.suscriptores[nombre] == nil then
        Eventos.suscriptores[nombre] = {}
    end

    table.insert(Eventos.suscriptores[nombre], funcion)
end

function Eventos.Emitir(nombre, ...)
    local lista = Eventos.suscriptores[nombre]

    if lista == nil then
        return
    end

    for i = 1, #lista do
        lista[i](...)
    end
end

function Eventos.Limpiar()
    Eventos.suscriptores = {}
end

return Eventos
