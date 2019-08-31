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
        @maxY = 165 * Screen.pixelH
        @offScreen = false
        @dead = false
        @autopilot = false
        @invulnerable = false
        @warping = false
        @cooldown = 0.3
        @hitbox = buildHitbox(@offsetX, @offsetY, 1, 4, 30, 12)

    update: (delta) ->
        if @cooldown > 0
#            console.log('cooldown', @cooldown)
            @cooldown -= delta
            if @cooldown < 0
                @cooldown = 0

    draw: (cameraOffsetX) ->
        @sprite.draw(@x + @offsetX - cameraOffsetX, @y + @offsetY, @facingLeft)

    moveV: (delta, direction) ->
        if @warping
            target = Game.world.blockToPixelH(13)
#            console.log(target, @y)
            if Math.abs(target - @y) < 2
                @y = target
            else if @y > target
                @y -= 1
            else
                @y += 1
        else
            @y += direction * delta * @vSpeed
            if @y < @minY then @y = @minY
            if @y > @maxY then @y = @maxY


    moveH: (delta, direction) ->
        if @warping
            @x += delta * @hSpeed * 5
        else
            @x += direction * delta * @hSpeed
        @facingLeft = direction < 0

    fireShot: ->
        return if @warping
        if @cooldown > 0
            return
        shotSpeed = 200 * Screen.pixelW
        shotOffset = 14 * Screen.pixelW
        if @facingLeft
            shotSpeed *= -1
            shotOffset *= -1

        Game.world.getNextPlayerShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed)
        @cooldown = 0.2


class PlayerShot
    constructor: ->
        @sprite = sprites.playerShot
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true
        @hitbox = buildHitbox(@offsetX, @offsetY, 0, -1, 14, 6)

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