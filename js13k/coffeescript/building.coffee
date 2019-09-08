class Building extends Enemy
    constructor: (@x, @y) ->
        @sprite = sprites.building

        super

        @offsetY = -@h
        @canBeDestroyed = false
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 3, 13, 32)



class Mine extends Enemy
    constructor: (@x, @y) ->
        @sprite = sprites.mine
        super
        @points = 100
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 1, 15, 15)

    onExplode: ->
        shotSpeed = 50 * Screen.pixelD
        for direction in [0, Math.PI, -Math.PI/2, Math.PI/2]
            Game.world.getNextEnemyShot().fire(@x, @y, shotSpeed, direction)


class Radar extends Enemy
    constructor: (@x, @y) ->
        @sprite = sprites.radar
        super
        @offsetY = -@h
        @cooldown = Math.random()
        @firePattern = [3, 0.5]
        @patternIndex = 0
        @points = 100
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 2, 15, 16)

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
window.Mine = Mine
window.Radar = Radar