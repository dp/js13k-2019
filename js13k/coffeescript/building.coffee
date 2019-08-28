class Building
    constructor: (@x, @y) ->
        @sprite = sprites.building
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = -@h
        @canBeDestroyed = false
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, 0, 14, 32)


    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, false)

    update: (delta) ->
        true


class Radar
    constructor: (@x, @y) ->
        @sprite = sprites.radar
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = -@h
        @cooldown = Math.random() * 5
        @firePattern = [3, 0.5]
        @patternIndex = 0
        @canBeDestroyed = true
        @points = 100
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, 0, 16, 16)

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, false)

    update: (delta) ->
        @cooldown -= delta
        if @cooldown < 0
            @fire() unless @offScreen
            @patternIndex += 1
            @patternIndex = 0 if @patternIndex == @firePattern.length
            @cooldown = @firePattern[@patternIndex]


    fire: ->
        shotSpeed = 50 * Screen.pixelD
        for direction in [Math.PI, -Math.PI/2, 0]
            Game.world.getNextEnemyShot().fire(@x - 3 * Screen.pixelW, @y - 13 * Screen.pixelH, shotSpeed, direction)


window.Building = Building
window.Radar = Radar