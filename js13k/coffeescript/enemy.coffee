class Enemy
    constructor: ->
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @direction ||= if Math.random() > 0.5 then 1 else -1
        @facingLeft = @direction < 0
        @canBeDestroyed = true

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, @facingLeft)

    update: (delta) ->
        # do nothing
        true

    onExplode: ->
        # do nothing
        true


class EnemyShot
    constructor: ->
        @sprite = sprites.enemyShot
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true

    fire: (@x, @y, speed, directionRad) ->
        @dead = false
        @offScreen = false
        @hSpeed = (Math.cos(directionRad) * speed)
        @vSpeed = (Math.sin(directionRad) * speed)

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, false)

    update: (delta) ->
        @x += @hSpeed * delta
        @y += @vSpeed * delta
        if @offScreen
            @dead = true



window.Enemy = Enemy
window.EnemyShot = EnemyShot