class World
    constructor: (@level, @ship) ->
        @ctx = Screen.ctx
        @canvas = Screen.canvas
        @width = @blockToPixelW(25 * 8)
        @halfWidth = @width / 2
        @spawnWidth = @width - @blockToPixelW(3)
        @cameraX = @canvas.width / 2
        @offScreenDist = @cameraX + @blockToPixelW(2)
        # screen is 23 rows high
        # bottom is ground
        # top is radar
        # 2nd is score, lives etc
        # 20 rows playable
        @sky = @blockToPixelH(2)
        @ground = @blockToPixelH(22)
        @height = @ground - @sky
        @items = []
        @levelEnded = false

        @playerShots = new ItemPool(PlayerShot, 10)
        @enemyShots = new ItemPool(EnemyShot, 200)
        @particles = new ItemPool(Particle, 2000)

        @generate(@level)

    blockToPixelH: (block) ->
        block * 8 * Screen.pixelH

    blockToPixelW: (block) ->
        block * 8 * Screen.pixelW


    generate: (level) ->
        @levelEnded = false
        @items = []
        item.dead = true for item in @playerShots.pool
        item.dead = true for item in @enemyShots.pool
        item.dead = true for item in @particles.pool
        buildings = randInt(3)+4
        if level == 1
            ufos = 5
            radars = 3
        else if level == 2
            ufos = 8
            radars = 5
            mines = 0
            guppies = 0
        else if level == 3
            ufos = 5
            radars = 5
            mines = 4
            guppies = 0
        else if level == 4
            ufos = 3
            radars = 3
            mines = 0
            guppies = 10
        else if level == 5
            ufos = 5
            radars = 3
            mines = 0
            guppies = 0
            snakeStart = @ship.x + @spawnWidth / 2
            for i in [0.. 12]
                @items.push new Snake(snakeStart + i * 32 * Screen.pixelH, -1)
                @items.push new Snake(snakeStart + i * 32 * Screen.pixelH, 1)

        for i in [0...buildings]
            @items.push new Building(randInt(@spawnWidth), @ground)
        if radars
            for i in [0...radars]
                @items.push new Radar(randInt(@spawnWidth), @ground)
        if ufos
            for i in [0...ufos]
                @items.push new UFO(randInt(@spawnWidth), randInt(@blockToPixelH(11)) + @blockToPixelH(4.5))
        if mines
            for i in [0...mines]
                @items.push new Mine(randInt(@spawnWidth), randInt(@blockToPixelH(11)) + @blockToPixelH(4.5))
        if guppies
            for i in [0...guppies]
                @items.push new Guppie(randInt(@spawnWidth))
        @guppies = level > 1
        @nextGuppieSpawn = 30

    getNextPlayerShot: ->
        @playerShots.getNextItem()

    getNextEnemyShot: ->
        @enemyShots.getNextItem()

    addParticle: (x, y, directionRad, speed, colour) ->
        @particles.getNextItem().fire(x, y, directionRad, speed, colour)

    spawnGuppie: ->
        @nextGuppieSpawn = 30
        @items.push new Guppie(@ship.x + @spawnWidth / 2)

    update: (delta) ->
        if @guppies
            @nextGuppieSpawn -= delta
            if @nextGuppieSpawn < 0
                @spawnGuppie()

        unless @ship.dead || @ship.autopilot || @ship.warping
            if keysDown.right
                @ship.moveH(delta, 1)
            else if keysDown.left
                @ship.moveH(delta, -1)
            if keysDown.up
                @ship.moveV(delta, -1)
            else if keysDown.down
                @ship.moveV(delta, 1)
#            if keysDown.shift
#                @ship.switchDirection()
#                window.keysDown.shift = false
#

            @ship.update(delta)
            if keysDown.fire
                @ship.fireShot()

        if @ship.warping
            @ship.moveH(delta, 1)
            @ship.moveV(delta, 1)

        rhs = @ship.x + @halfWidth
        lhs = @ship.x - @halfWidth
        for item in @playerShots.pool
            @updateItem(item, delta, rhs, lhs)
        for item in @items
            @updateItem(item, delta, rhs, lhs)
        for item in @enemyShots.pool
            @updateItem(item, delta, rhs, lhs)
        for item in @particles.pool
            @updateItem(item, delta, rhs, lhs)
        unless @ship.dead || @ship.autopilot || @ship.warping
            @seeIfEnemyHit()
            @seeIfPlayerHit() unless @ship.invulnerable

    updateItem: (item, delta, rhs, lhs) ->
        return if item.dead
        item.update(delta)
        if item.x > rhs
            item.x -= @width
        else if item.x < lhs
            item.x += @width
        item.offScreen = (Math.abs(item.x - @ship.x) > @offScreenDist) || item.y < 9 * Screen.pixelH || item.y > @ground

    draw: ->
        # ground
        @ctx.fillStyle = Colours.GREEN
        offsetX = @ship.x - @cameraX
        @ctx.fillRect(0, @ground, @canvas.width, @blockToPixelH(1))
#        @ctx.fillRect(10 - offsetX, 0, 10, @canvas.height)
#        @ctx.fillStyle = Colours.PURPLE
#        @ctx.fillRect(@width - 10 - offsetX, 0, 10, @canvas.height)
        for item in @enemyShots.pool
            @drawItem(item, offsetX)
        for item in @items
            @drawItem(item, offsetX)
        for item in @playerShots.pool
            @drawItem(item, offsetX)
        for item in @particles.pool
            @drawItem(item, offsetX)
        if @ship.invulnerable
            @ctx.globalAlpha = 0.5
        @drawItem(@ship, offsetX)
        @ctx.globalAlpha = 1.0
#        @ship.draw(offsetX) unless @ship.dead
        @drawRadar()

    drawItem: (item, offsetX) ->
        return if item.dead || item.offScreen
        item.draw(offsetX)


    drawRadar: () ->
        offsetX = @ship.x
        offsetY = @sky
        ratioX = @canvas.width / @width
        ratioY = @blockToPixelH(1) / @height
        halfScreen = @canvas.width / 2
        @ctx.fillStyle = Colours.BLUE
        @ctx.fillRect(halfScreen - 12 * Screen.pixelW, Screen.pixelH, 25 * Screen.pixelW,  8 * Screen.pixelH)
        @ctx.fillStyle = Colours.WHITE
        @ctx.fillRect(0, 9 * Screen.pixelH, @canvas.width, Screen.pixelH)
        for item in @items
            if !item.dead
                x = (item.x - offsetX) * ratioX + halfScreen
                y = (item.y - offsetY) * ratioY
                @ctx.fillRect(x, y, Screen.pixelW, Screen.pixelH)
                if (item instanceof Building)
                    @ctx.fillRect(x, y-Screen.pixelH, Screen.pixelW, Screen.pixelH)

    seeIfPlayerHit: ->
        for shot in @enemyShots.pool
            if !shot.dead && @pointInHitbox(@ship, shot.x, shot.y)
                shot.dead = true
                @playerDies(shot.x, shot.y)
        for item in @items
            if !item.dead && @hitboxesIntersect(@ship, item)
                @playerDies(@ship.x, @ship.y)

    seeIfEnemyHit: ->
        for shot in @playerShots.pool
            if !shot.dead
                for item in @items
                    if item.canBeDestroyed && !item.dead
                        if @hitboxesIntersect(shot, item)
                            shot.dead = true
                            @enemyDies(item, shot.x, shot.y, shot.hSpeed)


    hitboxesIntersect: (item1, item2) ->
#        return false unless item1.hitbox && item2.hitbox
#        return false if Math.abs(item1.x - item2.x) > 30 * Screen.pixelW ||
#            Math.abs(item1.y - item2.y) > 50 * Screen.pixelH
#        h1 = item1.hitbox
#        h2 = item2.hitbox
#        x1 = item1.x
#        x2 = item2.x
#        y1 = item1.y
#        y2 = item2.y
        item1.x + item1.hitbox.right > item2.x + item2.hitbox.left &&
            item2.x + item2.hitbox.right > item1.x + item1.hitbox.left &&
            item1.y + item1.hitbox.bottom > item2.y + item2.hitbox.top &&
            item2.y + item2.hitbox.bottom > item1.y + item1.hitbox.top


    pointInHitbox: (item, pointX, pointY) ->
        return false unless item.hitbox
        pointX > item.x + item.hitbox.left &&
            pointX < item.x + item.hitbox.right &&
            pointY > item.y + item.hitbox.top &&
            pointY < item.y + item.hitbox.bottom

    playerDies: (hitPointX, hitPointY) ->
        return if @ship.dead
        hitPoint = {x: hitPointX - @ship.x, y: hitPointY - @ship.y}
        @explodeSprite(@ship, hitPoint, 1)
        Game.respawnPlayer()

    enemyDies: (enemy, hitPointX, hitPointY, hitSpeed) ->
        # hitSpeed +ve if travelling right, -ve for left
        hitPoint = {x: hitPointX - enemy.x, y: hitPointY - enemy.y}
        @explodeSprite(enemy, hitPoint, hitSpeed)
        enemy.onExplode()
        enemy.dead = true
        Game.score += enemy.points
        Game.kills += 1
        enemiesRemaining = 0
        for item in @items
            if !item.dead && item.canBeDestroyed
                enemiesRemaining += 1
#        console.log {enemiesRemaining}
        if enemiesRemaining == 0
            Game.warpToNextWorld()

    explodeSprite: (gameItem, point, direction) ->
        sprite = gameItem.sprite
        imageData = sprite.getImageData(gameItem.facingLeft)
        width = sprite.imageW
        height = sprite.imageH
        dOffset = if direction > 0 # gameItem.x + gameItem.offsetX > point.x
                    10 * Screen.pixelW
                else
                    -10 * Screen.pixelW
        origin = {x:0, y:0}
#        console.log gameItem.x, gameItem.y, point.x, point.y, gameItem.offsetX
        for y in [0...height] by Screen.pixelH
            for x in [0...width] by Screen.pixelW
                offset =  y * (width * 4) + x * 4
                r = imageData[offset]
                g = imageData[offset + 1]
                b = imageData[offset + 2]
                a = imageData[offset + 3]
                if a > 0
                    pixel = {x:x + gameItem.offsetX, y:y + gameItem.offsetY}
                    if Math.abs(point.y - pixel.y) < 3 * Screen.pixelH
                        v1 = Vectors.angleDistBetweenPoints point, {x: (dOffset + pixel.x) * 15, y: pixel.y}
                    else
                        v1 = Vectors.angleDistBetweenPoints point, pixel
                    #want pixels horizontal with shot to explode out much more as shot follow-through
#                    v2 = Vectors.angleDistBetweenPoints origin, pixel
#                    v1.distance = 250
#                    v2 = Vectors.addVectors v1.angle, v1.distance, direction, 100
#                    v = Vectors.addVectors v1.angle, v1.distance + 100, v2.angle, v2.distance
#                    console.log(v)
                    pixel.x += gameItem.x
                    pixel.y += gameItem.y

                    @addParticle(pixel.x, pixel.y, v1.angle, v1.distance / 2 + 300, {r,g,b})


window.World = World