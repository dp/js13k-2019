class Particle
    constructor: () ->
        @w = Screen.pixelW * 1.5
        @h = Screen.pixelH * 1.5
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true
        @maxLife = Math.random() + 2
        @colour = {}
        @drag = 0.985

    fire: (@x, @y, directionRad, speed, rgbValues) ->
        directionRad += Math.random() / 10 - 0.05
        speed *= 0.9 + Math.random() * 0.2
        @dead = false
        @offScreen = false
        @hSpeed = (Math.cos(directionRad) * speed)
        @vSpeed = (Math.sin(directionRad) * speed)
        @life = @maxLife
        @initColour(rgbValues)

    draw: (cameraOffsetX) ->
        Screen.ctx.fillStyle = @colour.hexString + @colour.alphaHex
        Screen.ctx.fillRect(@x + @offsetX - cameraOffsetX, @y + @offsetY, @w, @h)

    update: (delta) ->
        @hSpeed *= @drag
        @vSpeed *= @drag
        @x += @hSpeed * delta
        @y += @vSpeed * delta
        @life -= delta
        if @life <= 0
            @dead = true
        else
            ratio = @life / @maxLife
            if ratio < 0.5
                alpha = Math.round(ratio * 2 * 255).toString(16)
                alpha = '0' + alpha if alpha.length == 1
                @colour.alphaHex = alpha


    initColour: (rgbValues) ->
        r = rgbValues.r.toString(16)
        r = '0' + r if r.length == 1
        g = rgbValues.g.toString(16)
        g = '0' + g if g.length == 1
        b = rgbValues.b.toString(16)
        b = '0' + b if b.length == 1
        @colour.rgb = rgbValues
        @colour.hexString = '#'+r+g+b
        @colour.alphaHex = 'ff'


window.Particle = Particle