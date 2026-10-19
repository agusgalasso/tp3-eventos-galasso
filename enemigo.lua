
local Animacion = require("Animacion")

local Enemigo = {}
Enemigo.__index = Enemigo

function Enemigo:Nuevo()
    local objeto = setmetatable({}, Enemigo)

    objeto.x = 480
    objeto.y = 460
    objeto.ancho = 40
    objeto.alto = 40
    objeto.velocidad = 130
    objeto.direccion = 1
    objeto.limiteIzquierdo = 350
    objeto.limiteDerecho = 740
    objeto.animacion = Animacion:Nueva(
        "img/enemigo.png", 32, 32, 0.15
    )

    return objeto
end

function Enemigo:Actualizar(dt)
    self.x = self.x + self.velocidad * self.direccion * dt

    if self.x + self.ancho >= self.limiteDerecho then
        self.x = self.limiteDerecho - self.ancho
        self.direccion = -1
    elseif self.x <= self.limiteIzquierdo then
        self.x = self.limiteIzquierdo
        self.direccion = 1
    end

    self.animacion:Actualizar(dt)
end

function Enemigo:Dibujar()
    if self.animacion:Dibujar(
        self.x, self.y, self.ancho, self.alto
    ) then
        return
    end

    love.graphics.setColor(0.9, 0.2, 0.25)

    love.graphics.rectangle(
        "fill", self.x, self.y, self.ancho, self.alto
    )
end

return Enemigo
