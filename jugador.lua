
local Eventos = require("Eventos")
local Animacion = require("Animacion")

local Jugador = {}
Jugador.__index = Jugador

function Jugador:Nuevo()
    local objeto = setmetatable({}, Jugador)

    objeto.x = 60
    objeto.y = 400
    objeto.inicioX = 60
    objeto.inicioY = 400
    objeto.ancho = 40
    objeto.alto = 50
    objeto.velocidad = 250
    objeto.velocidadY = 0
    objeto.fuerzaSalto = -450
    objeto.gravedad = 1000
    objeto.enSuelo = false
    objeto.vidas = 3
    objeto.tiempoInvulnerable = 0
    objeto.direccion = 1
    objeto.animacion = Animacion:Nueva(
        "img/jugador.png", 32, 32, 0.12
    )

    return objeto
end

function Jugador:Actualizar(dt)
    if self.tiempoInvulnerable > 0 then
        self.tiempoInvulnerable =
            math.max(0, self.tiempoInvulnerable - dt)
    end

    local moviendo = false

    if love.keyboard.isDown("right") or love.keyboard.isDown("d") then
        self.x = self.x + self.velocidad * dt
        self.direccion = 1
        moviendo = true
    end

    if love.keyboard.isDown("left") or love.keyboard.isDown("a") then
        self.x = self.x - self.velocidad * dt
        self.direccion = -1
        moviendo = true
    end

    self.velocidadY = self.velocidadY + self.gravedad * dt
    self.y = self.y + self.velocidadY * dt

    local sueloY = 500

    if self.y + self.alto >= sueloY then
        self.y = sueloY - self.alto
        self.velocidadY = 0
        self.enSuelo = true
    else
        self.enSuelo = false
    end

    self.x = math.max(
        0,
        math.min(800 - self.ancho, self.x)
    )

    if moviendo then
        self.animacion:Actualizar(dt)
    end
end

function Jugador:Saltar()
    if self.enSuelo then
        self.velocidadY = self.fuerzaSalto
        self.enSuelo = false
        Eventos.Emitir("jugador_salto")
    end
end

function Jugador:RecibirDanio()
    if self.tiempoInvulnerable > 0 or self.vidas <= 0 then
        return
    end

    self.vidas = self.vidas - 1
    self.tiempoInvulnerable = 1

    self.x = self.inicioX
    self.y = self.inicioY
    self.velocidadY = 0

    Eventos.Emitir("jugador_daniado")
    Eventos.Emitir("vidas_actualizadas", self.vidas)

    if self.vidas <= 0 then
        Eventos.Emitir("jugador_derrotado")
    end
end

function Jugador:Dibujar()
    if self.tiempoInvulnerable > 0
        and math.floor(self.tiempoInvulnerable * 10) % 2 == 0 then
        return
    end

    if self.animacion:Dibujar(
        self.x, self.y, self.ancho, self.alto
    ) then
        return
    end

    if self.direccion == 1 then
        love.graphics.setColor(0.2, 0.6, 1)
    else
        love.graphics.setColor(0.3, 0.8, 1)
    end

    love.graphics.rectangle(
        "fill", self.x, self.y, self.ancho, self.alto
    )
end

return Jugador
