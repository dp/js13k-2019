class UFO extends Enemy
    constructor: (@x, @base) ->
        @sprite = sprites.ufo
        @y = @base
        @vSpeed = 200 * Screen.pixelH # unused
        @hSpeed = 30 * Screen.pixelW

        super

        @points = 50
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 2, 14, 6)

    update: (delta) ->
        @x += @direction * @hSpeed * delta
        @y = @base + Math.sin(@x / 100) * 10 * Screen.pixelH
        if !@offScreen && Math.random() > 0.99
            @fire()

    fire: ->
        shotOffset = Screen.pixelW * 4
        shotSpeed = 20 * Screen.pixelD
        direction = Math.random() * Math.PI * 2
        Game.world.getNextEnemyShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed, direction)


class Guppie extends Enemy
    constructor: (@x) ->
        @sprite = sprites.seeker
        @y = 100
        @vSpeed = 15 * Screen.pixelH
        @hSpeed = 40 * Screen.pixelW

        super

        @points = 150
        @hitbox = buildHitbox(@offsetX, @offsetY, 2, 2, 12, 8)

    setRandomTargetDelta: ->
        @targetDeltaX = (randInt(200) - 100) * Screen.pixelW
        @targetY = (randInt(130) + 30) * Screen.pixelH

    update: (delta) ->
        targetX = Game.ship.x + @targetDeltaX
        deltaX = targetX - @x
        deltaY = @targetY - @y
        if Math.abs(deltaX) > 10
            if deltaX > 0
                @direction = 1
                @facingLeft = false
            else
                @direction = - 1
                @facingLeft = true
            @x += @direction * @hSpeed * delta
        else
            @setRandomTargetDelta()

        if Math.abs(deltaY) > 10
            if deltaY > 0
                @direction = 1
            else
                @direction = - 1
            @y += @direction * @vSpeed * delta

        if !@offScreen && Math.random() > 0.99
            @fire()

    fire: ->
        shotOffset = Screen.pixelW * 4
        shotSpeed = 20 * Screen.pixelD
        direction = Math.random() * Math.PI * 2
        Game.world.getNextEnemyShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed, direction)


window.UFO = UFO
window.Guppie = Guppie
