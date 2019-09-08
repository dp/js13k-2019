class Snake extends Enemy
    constructor: (@x, @direction) ->
        @sprite = sprites.snake
        @base = Screen.pixelH * 8 * 10
        @y = @base
        @vSpeed = 200 * Screen.pixelH # unused
        @hSpeed = 30 * Screen.pixelW

        super

#        @direction = direction
        @points = 100
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 2, 14, 14)

    update: (delta) ->
        @x += @direction * @hSpeed * delta
        @y = @base + Math.sin(@x / 200) * 8 * 7 * Screen.pixelH
        if !@offScreen && Math.random() > 0.991
            @fire()

    fire: ->
        shotSpeed = 150 * Screen.pixelH
        Game.world.getNextEnemyShot().fire(@x, @y, shotSpeed, 0)
        Game.world.getNextEnemyShot().fire(@x, @y, shotSpeed, Math.PI)

window.Snake = Snake