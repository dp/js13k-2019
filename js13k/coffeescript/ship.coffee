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
        @maxVSpeed = 120 * Screen.pixelH
        @maxHSpeed = 180 * Screen.pixelW
        @vThrust = 3000
        @hThrust = 3000
        @vSpeed = 0
        @hSpeed = 0
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
        unless @warping
            @y += @vSpeed * delta
            if @y < @minY then @y = @minY
            if @y > @maxY then @y = @maxY
            @x += @hSpeed * delta
            # very high braking if user not actively moving
            unless @movingV
                @vSpeed *= 0.8
            unless @movingH
                @hSpeed *= 0.8
        @movingV = false
        @movingH = false


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
            @vSpeed += @vThrust * delta * direction
            if @vSpeed > @maxVSpeed then @vSpeed = @maxVSpeed
            else if @vSpeed < -@maxVSpeed then @vSpeed = -@maxVSpeed
            @movingV = true


    moveH: (delta, direction) ->
        if @warping
            @x += delta * @maxHSpeed * 5
        else
            @hSpeed += @hThrust * delta * direction
            if @hSpeed > @maxHSpeed then @hSpeed = @maxHSpeed
            else if @hSpeed < -@maxHSpeed then @hSpeed = -@maxHSpeed
            @movingH = true
        @facingLeft = direction < 0

    switchDirection: ->
        @facingLeft = !@facingLeft

    fireShot: ->
        return if @warping
        if @cooldown > 0
            return
        shotSpeed = 250 * Screen.pixelW
        shotOffset = 14 * Screen.pixelW
        if @facingLeft
            shotSpeed *= -1
            shotOffset *= -1

        Game.world.getNextPlayerShot().fire(@x + shotOffset, @y + 2 * Screen.pixelH, shotSpeed)
        Game.shotsFired += 1
        @cooldown = 0.2


class PlayerShot
    constructor: ->
        @sprite = sprites.playerShot
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true
        @hitbox = buildHitbox(@offsetX, @offsetY, 2, -4, 14, 6)

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