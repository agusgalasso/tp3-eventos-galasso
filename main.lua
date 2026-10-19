
local Eventos = require("Eventos")
local Jugador = require("Jugador")
local Enemigo = require("Enemigo")
local HUD = require("HUD")
local Sonido = require("Sonido")

local jugador
local enemigo
local hud
local sonido

local estadoJuego = "menu"
local puntaje = 0
local moneda
local monedaImagen
local meta

local function reiniciarJuego()
    jugador.x = jugador.inicioX
    jugador.y = jugador.inicioY
    jugador.velocidadY = 0
    jugador.vidas = 3
    jugador.enSuelo = false
    jugador.tiempoInvulnerable = 0

    enemigo.x = 480
    enemigo.direccion = 1

    puntaje = 0
    moneda.recolectada = false
    estadoJuego = "jugando"

    hud:Reiniciar()

    Eventos.Emitir("vidas_actualizadas", jugador.vidas)
    Eventos.Emitir("puntaje_actualizado", puntaje)
end

local function colisionan(a, b)
    return a.x < b.x + b.ancho
        and a.x + a.ancho > b.x
        and a.y < b.y + b.alto
        and a.y + a.alto > b.y
end

function love.load()
    love.window.setMode(800, 600)
    love.window.setTitle("La aventura de las señales")

    love.graphics.setBackgroundColor(0.08, 0.12, 0.22)

    jugador = Jugador:Nuevo()
    enemigo = Enemigo:Nuevo()
    hud = HUD:Nuevo()
    sonido = Sonido:Nuevo()

    moneda = {
        x = 300,
        y = 455,
        ancho = 24,
        alto = 24,
        recolectada = false
    }

    meta = {
        x = 735,
        y = 450,
        ancho = 40,
        alto = 50
    }

    if love.filesystem.getInfo("img/moneda.png") then
        monedaImagen = love.graphics.newImage("img/moneda.png")
    end

    Eventos.Suscribir("jugador_derrotado", function()
        estadoJuego = "derrota"
    end)
end

function love.update(dt)
    if estadoJuego ~= "jugando" then
        return
    end

    jugador:Actualizar(dt)
    enemigo:Actualizar(dt)
    hud:Actualizar(dt)

    if colisionan(jugador, enemigo) then
        jugador:RecibirDanio()
    end

    if not moneda.recolectada and colisionan(jugador, moneda) then
        moneda.recolectada = true
        puntaje = puntaje + 10

        Eventos.Emitir("moneda_recolectada")
        Eventos.Emitir("puntaje_actualizado", puntaje)
    end

    if colisionan(jugador, meta) then
        estadoJuego = "victoria"
        Eventos.Emitir("jugador_victoria")
    end
end

local function dibujarPlataforma()
    love.graphics.setColor(0.25, 0.65, 0.35)

    love.graphics.rectangle(
        "fill", 0, 500, 800, 100
    )

    love.graphics.setColor(0.4, 0.8, 0.45)

    love.graphics.rectangle(
        "fill", 0, 500, 800, 8
    )
end

local function dibujarMoneda()
    if moneda.recolectada then
        return
    end

    if monedaImagen then
        love.graphics.setColor(1, 1, 1)

        love.graphics.draw(
            monedaImagen,
            moneda.x,
            moneda.y,
            0,
            moneda.ancho / monedaImagen:getWidth(),
            moneda.alto / monedaImagen:getHeight()
        )
    else
        love.graphics.setColor(1, 0.75, 0.1)

        love.graphics.circle(
            "fill",
            moneda.x + moneda.ancho / 2,
            moneda.y + moneda.alto / 2,
            moneda.ancho / 2
        )
    end
end

local function dibujarMeta()
    love.graphics.setColor(0.95, 0.8, 0.15)

    love.graphics.rectangle(
        "fill",
        meta.x,
        meta.y,
        meta.ancho,
        meta.alto
    )

    love.graphics.setColor(0.1, 0.1, 0.1)

    love.graphics.print("META", meta.x - 3, meta.y - 20)
end

local function dibujarMensaje(titulo, instruccion)
    love.graphics.setColor(1, 1, 1)

    love.graphics.printf(
        titulo,
        0, 220, 800, "center"
    )

    love.graphics.printf(
        instruccion,
        0, 270, 800, "center"
    )
end

function love.draw()
    if estadoJuego == "menu" then
        dibujarMensaje(
            "LA AVENTURA DE LAS SEÑALES",
            "Presiona ENTER para comenzar"
        )

        love.graphics.setColor(1, 1, 1)

        love.graphics.printf(
            "Recoge la moneda y llega a la meta sin perder tus vidas.",
            50, 330, 700, "center"
        )

        return
    end

    dibujarPlataforma()
    dibujarMeta()
    dibujarMoneda()

    if estadoJuego == "jugando" then
        enemigo:Dibujar()
        jugador:Dibujar()
        hud:Dibujar()

    elseif estadoJuego == "victoria" then
        enemigo:Dibujar()
        jugador:Dibujar()
        hud:Dibujar()

        dibujarMensaje(
            "¡GANASTE!",
            "Presiona R para volver a jugar"
        )

    elseif estadoJuego == "derrota" then
        enemigo:Dibujar()
        jugador:Dibujar()
        hud:Dibujar()

        dibujarMensaje(
            "¡PERDISTE!",
            "Presiona R para volver a jugar"
        )
    end

    love.graphics.setColor(1, 1, 1)
end

function love.keypressed(tecla)
    if estadoJuego == "menu" then
        if tecla == "return" or tecla == "kpenter" then
            reiniciarJuego()
        end

        return
    end

    if estadoJuego == "jugando" then
        if tecla == "space" then
            jugador:Saltar()
        end
    elseif tecla == "r" then
        reiniciarJuego()
    end
end
