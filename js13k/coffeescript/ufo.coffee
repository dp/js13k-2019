class UFO
    constructor: (@x, @base) ->
        @sprite = sprites.ufo
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @y = @base
        @direction = if Math.random() > 0.5 then 1 else -1
        @facingLeft = @direction < 0
        @vSpeed = 200 * Screen.pixelH # unused
        @hSpeed = 30 * Screen.pixelW
        @canBeDestroyed = true
        @points = 50
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, 0, 16, 9)

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, @facingLeft)

    update: (delta) ->
        @x += @direction * @hSpeed * delta
        @y = @base + Math.sin(@x / 100) * 30
        if !@offScreen && Math.random() > 0.99
            @fire()

    fire: ->
        shotOffset = Screen.pixelW * 4
        shotSpeed = 20 * Screen.pixelD
        direction = Math.random() * Math.PI * 2
        Game.world.getNextEnemyShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed, direction)



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
#            console.log 'Shot offscreen'
            @dead = true



window.UFO = UFO
window.EnemyShot = EnemyShot