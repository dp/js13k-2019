class Ship
    constructor: ->
        @sprite = sprites.ship
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @x = 100
        @y = 100
        @facingLeft = false
        @vSpeed = 100 * Screen.pixelH
        @hSpeed = 150 * Screen.pixelW
        @minY = 18 * Screen.pixelH
        @maxY = 168 * Screen.pixelH
        @offScreen = false
        @cooldown = 0.3
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, 0, 32, 13)

    update: (delta) ->
        if @cooldown > 0
#            console.log('cooldown', @cooldown)
            @cooldown -= delta
            if @cooldown < 0
                @cooldown = 0

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, @facingLeft)

    moveV: (delta, direction) ->
        @y += direction * delta * @vSpeed
        if @y < @minY then @y = @minY
        if @y > @maxY then @y = @maxY


    moveH: (delta, direction) ->
        @x += direction * delta * @hSpeed
        @facingLeft = direction < 0

    fireShot: ->
        if @cooldown > 0
            return
        shotSpeed = 200 * Screen.pixelW
        shotOffset = 14 * Screen.pixelW
        if @facingLeft
            shotSpeed *= -1
            shotOffset *= -1

        Game.world.getNextPlayerShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed)
        @cooldown = 0.1


class PlayerShot
    constructor: ->
        @sprite = sprites.playerShot
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, 1, 16, 4)

    fire: (@x, @y, @hSpeed) ->
        @dead = false
        @offScreen = false
        @facingLeft = @hSpeed < 0

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, @facingLeft)

    update: (delta) ->
        @x += @hSpeed * delta
        if @offScreen
            @dead = true

window.Ship = Ship
window.PlayerShot = PlayerShot