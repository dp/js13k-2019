Colours =
    BLACK:  '#000000'
    WHITE:  '#ffffff'
    RED:    '#e32d2d'
#    PINK: '#b66862'
    CYAN:   '#2de3e3'
#    LIGHT_CYAN: '#c5ffff'
#    PURPLE: '#e32de3'
    PURPLE: '#b31de3'
#    LIGHT_PURPLE: '#e99df5'
    GREEN:  '#2dc32d'
#    LIGHT_GREEN: '#92df87'
    BLUE:   '#2d2de3'
#    LIGHT_BLUE: '7e70ca'
    YELLOW: '#e3e32d'
#    LIGHT_YELLOW: '#ffffb0'
#    ORANGE: '#a8734a'
#    LIGHT_ORANGE: '#e9b287'

Cursor =
    x: 0
    y: 0
    visible: false
    blinkTimer: null
    blinkStateOn: true

    show: ->
        @blinkTimer ||= setInterval(Cursor.blink, 500)
        @visible = true
        @blinkStateOn = true
        @draw()

    hide: ->
        clearInterval(@blinkTimer)
        @blinkTimer = null
        @blinkStateOn = false
        @draw()
        @visible = false


    blink: ->
        Cursor.blinkStateOn = !Cursor.blinkStateOn
        Cursor.draw()

    draw: ->
        if @visible
            colour = if @blinkStateOn then Screen.textColour else Screen.screenColour
            Screen.drawCharRect(Cursor.x, Cursor.y, colour)

    moveTo: (newX, newY) ->
        if @visible
            Screen.drawCharRect(Cursor.x, Cursor.y, Screen.screenColour)
        Cursor.x = newX
        Cursor.y = newY
        @draw()

    newLine: ->
        @moveTo(0, Cursor.y + 1)

Screen =
    screenColour: Colours.WHITE
    textColour: Colours.BLUE
    colour2: Colours.YELLOW
    colour3: Colours.RED

# standard screen size is 176 * 184
# 22 columns, 23 rows
    columnsWide: 22
    rowsHigh: 23
    pixelW: 5
    pixelH: 3

    init: (pixelW, pixelH)->
        @pixelW = pixelW
        @pixelH = pixelH
        @pixelD = Math.sqrt(@pixelW * @pixelW + @pixelH * @pixelH)
        @canvas = document.getElementById('game')
        @ctx = @canvas.getContext("2d")
        @setSize(@columnsWide, @rowsHigh)
        @clear()

    clear: ->
        @ctx.fillStyle = @screenColour
        @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
        Cursor.x = 0
        Cursor.y = 0

    setBorder: (colour) ->
        document.body.style.backgroundColor = colour

    setSize: (newCols, newRows) ->
        @columnsWide = newCols
        @rowsHigh = newRows
        @canvas.width = @columnsWide * 8 * @pixelW
        @canvas.height = @rowsHigh * 8 * @pixelH

    setCursor: (col, row) ->
        Cursor.x = col
        Cursor.y = row

    moveCursor: ->
        x = Cursor.x + 1
        y = Cursor.y
        if x == @columnsWide
            x = 0
            y = Cursor.y + 1
            if y == @rowsHigh
                y = 0
        Cursor.moveTo(x, y)

    drawCharRect: (x, y, colour) ->
        @ctx.fillStyle = colour
        @ctx.fillRect(x * 8 * @pixelW, y * 8 * @pixelH, 8 * Screen.pixelW, 8 * Screen.pixelH)

    drawCharAtCursor: (charCode) ->
        char = charBytes[charCode]
        x = Cursor.x * 8 * @pixelW
        y = Cursor.y * 8 * @pixelH
        @moveCursor()
        #        @drawCharRect(Cursor.x, Cursor.y, @screenColour)
        #        @ctx.fillStyle = @screenColour
        #        @ctx.fillRect(x, y, 8 * Screen.pixelW, 8 * Screen.pixelH)
        @ctx.fillStyle = @textColour
        char.forEach (byte) ->
            i = 0
            while i < 8
                if byte & 2 ** (7 - i)
                    Screen.ctx.fillRect x + i * Screen.pixelW, y, Screen.pixelW, Screen.pixelH
                i++
            y += Screen.pixelH
        true

    print: (text) ->
#        @setCursor(col, row)
        for i in [0...text.length]
#            console.log(text[i], text.charCodeAt(i), @asciiToVic(text.charCodeAt(i)))
            this.drawCharAtCursor(@asciiToVic(text.charCodeAt(i)))

    println: (text) ->
        @print(text)
        Cursor.newLine()

    printAt: (col, row, text) ->
        Cursor.moveTo(col, row)
        @print(text)

    asciiToVic: (ascii) ->
        ascii
#        if ascii < 32  then 128
#        else if ascii < 64  then ascii
#        else if ascii < 96  then ascii-64
#        else if ascii < 128 then ascii+160
#        else if ascii < 160 then ascii-128
#        else if ascii < 192 then ascii-64
#        else if ascii < 255 then ascii-128
#        else 94

    drawSprite: (x, y, sprite) ->
        x = x * @pixelW
        y = y * @pixelH

        for line in sprite.trim().split("\n")
            offset = 0

            for byteStr in line.match(/(..?)/g)
                byte = parseInt(byteStr, 16)
                for i in [0..3]
                    bits = byte & 0b11000000
                    colour =
                        if bits == 0b00000000
                            null
                        else if bits == 0b01000000
                            @textColour
                        else if bits == 0b10000000
                            @colour2
                        else if bits == 0b11000000
                            @colour3
                    if colour
                        @ctx.fillStyle = colour
                        @ctx.fillRect(x + offset * Screen.pixelW, y, Screen.pixelW * 2, Screen.pixelH)
                    offset += 2
                    byte = byte << 2
            y += Screen.pixelH
        true



window.Screen = Screen
window.Colours = Colours
window.Cursor = Cursor

GameStates =
    PRE_LAUNCH: 'PRE_LAUNCH'
    TITLE_SCREEN: 'TITLE_SCREEN'
    PLAYING_IN_PLAY: 'PLAYING_IN_PLAY'
    PLAYING_WARPING: 'PLAYING_WARPING'
    START_OF_LEVEL: 'START_OF_LEVEL'
    PLAYING_SPAWNING: 'PLAYING_SPAWNING'
    GAME_OVER: 'GAME_OVER'

Game =
    state: GameStates.PRE_LAUNCH

    run: ->
        @ctx = Screen.ctx
        @canvas = Screen.canvas
        @cooldown = 0
        Screen.setSize(25, 23)
        Screen.screenColour = Colours.BLACK
        Screen.textColour = Colours.WHITE
        Screen.setBorder(Colours.BLUE)
        Cursor.hide()
        addChars(48, astroDigits)
        @showTitleScreen()
        requestAnimationFrame update

    update: (timestamp) ->
        if @lastTimestamp
            delta = (timestamp - @lastTimestamp) / 1000
        else
            delta = 0
        @lastTimestamp = timestamp
        @cooldown -= delta

        #        if @state != @lastState
        #            console.log 'Changed state to ', @state
        #            @lastState = @state

        if @state == GameStates.TITLE_SCREEN
            if keysDown.fire && @cooldown <= 0
                @startGame()

        else
            if @state == GameStates.GAME_OVER
                if keysDown.fire && @cooldown <= 0
                    @state = GameStates.TITLE_SCREEN
                    @cooldown = 1
                    @showTitleScreen()

            else if @state == GameStates.PLAYING_SPAWNING
                if @cooldown < 0
                    @state = GameStates.PLAYING_IN_PLAY
                    @ship.invulnerable = false
                else if @cooldown < 2
                    @ship.dead = false
                    @ship.autopilot = false
                    @ship.invulnerable = true

            else if @state == GameStates.PLAYING_WARPING
                if @cooldown < 0
                    @state = GameStates.PLAYING_SPAWNING
                    @ship.autopilot = false
                    @ship.invulnerable = true
                    @ship.warping = false
                    @cooldown = 2
                else if @cooldown < 2 && @world.levelEnded
                    @level += 1
                    @world.generate(@level)
        #
        #            else if @state == GameStates.PLAYING_IN_PLAY
        #                true
        # do nothing
        unless @state == GameStates.TITLE_SCREEN
            @world.update(delta)
            @draw()

    draw: ->
        if @state == GameStates.PLAYING_WARPING
            Screen.screenColour = Colours.PURPLE
            Screen.clear()
            Screen.textColour = Colours.WHITE
            levelText = if @world.levelEnded
                @level
            else
                @level - 1
            Screen.printAt 5, 8, "LEVEL #{levelText} CLEARED"
            Screen.printAt 8, 10, 'WARPING ...'
            Screen.textColour = Colours.BLUE
        else
            @ctx.fillStyle = Colours.BLACK
            @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
            Screen.textColour = Colours.WHITE

        Screen.printAt 1, 2, ''+@score
        Screen.printAt 12, 2, ''+@level
        if @livesLeft > 0
            for i in [1..@livesLeft]
                Screen.printAt 24 - i, 2, '/' # prints a heart character
        @world.draw()

        if @state == GameStates.GAME_OVER
            Screen.textColour = Colours.WHITE
            Screen.printAt 8, 8, 'GAME OVER'
            if @cooldown < 0
                Screen.printAt 7, 10, 'Press  FIRE'

    startGame: ->
        @state = GameStates.PLAYING_SPAWNING
        Screen.clear()
        Screen.printAt 8, 4, "Playing ..."
        @score = 0
        @livesLeft = 4
        @level = 1
        @ship = new Ship()
        @world = new World(1, @ship)
        @cooldown = 2

    warpToNextWorld: ->
        @state = GameStates.PLAYING_WARPING
        @cooldown = 5
        @ship.warping = true
        @world.levelEnded = true


    endGame: ->
        @state = GameStates.GAME_OVER
        @cooldown = 3

    respawnPlayer: ->
        @ship.dead = true
        @ship.autopilot = true
        if @livesLeft == 0
            @endGame()
        else
            @livesLeft -= 1
            @ship.y = 8 * 12 * Screen.pixelH
            @state = GameStates.PLAYING_SPAWNING
            @cooldown = 3


    hLine: (row) ->
        Screen.printAt 0, row, ';;;;;;;;;;;;;;;;;;;;;;;;;'


    showTitleScreen: ->
        @state = GameStates.TITLE_SCREEN
        Screen.screenColour = Colours.BLACK
        Screen.clear()
        Screen.printAt 8, 4, "ASTROBLITZ"
        #        @hLine(5)
        Screen.printAt 0, 6, "(C)1982 CREATIVE SOFTWARE"
        @hLine(7)

        Screen.printAt 15, 9, "50"
        Screen.printAt 15, 12, "50"
        Screen.printAt 15, 15, "100"
        Screen.printAt 15, 18, "150"

        Screen.printAt 1, 10, "MOVE"
        Screen.printAt 1, 12, "OR"
        Screen.printAt 1, 16, "FIRE"
        @hLine(20)
        @hLine(22)
        Screen.textColour = Colours.YELLOW
        Screen.printAt 3, 21, 'PRESS SPACE TO START'
        Screen.textColour = Colours.CYAN
        Screen.printAt 1, 11, "^ _ $ %"
        Screen.printAt 1, 13, "W A S D"
        Screen.printAt 1, 17, "SPACE"

        Screen.textColour = Colours.BLUE
        Screen.drawSprite(96, 71, ufo)
        Screen.drawSprite(96, 88, radar)
        Screen.drawSprite(96, 112, mine)
        Screen.drawSprite(96, 140, guppie)
#        Screen.drawSprite(50, 50, building)
#        Screen.drawSprite(70, 50, ship)

window.update = (timestamp) ->
    Game.update(timestamp)
    if window.paused
        console.log 'Game is paused'
    else
        window.requestAnimationFrame update
    true

# Keys states (false: key is released / true: key is pressed)
window.keysDown =
    left: false
    right: false
    up: false
    down: false
    fire: false
window.paused = false

window.keyToggled = (keyCode, isPressed) ->
    if keyCode == 32
        window.keysDown.fire = isPressed
    # Up (up / W / Z)
    if(keyCode == 38 || keyCode == 90 || keyCode == 87)
        window.keysDown.up = isPressed
    # Right (right / D)
    if(keyCode == 39 || keyCode == 68)
        window.keysDown.right = isPressed
    # Down (down / S)
    if(keyCode == 40 || keyCode == 83)
        window.keysDown.down = isPressed
    # Left (left / A / Q)
    if(keyCode == 37 || keyCode == 65 ||keyCode == 81)
        window.keysDown.left = isPressed
    if(keyCode == 66)
        window.paused = isPressed
        console.log('Paused', window.paused)

# Key listeners
window.onkeydown = (e) ->
    keyToggled(e.keyCode, true)

window.onkeyup = (e) ->
    keyToggled(e.keyCode, false)


window.Game = Game
window.GameStates = GameStates
Typer =
    command: null
    commandPos: 0

    display: (@commands, @callback) ->
        @execNextCommand()

    execNextCommand: ->
        if @commands.length == 0
            @callback?()
            return
        command = @commands.shift().split(':')
        @commandText = command[1]
        @command = command[0]
        @commandPos = 0
        #        console.log({@command, @commandText})
        @execCommand()

    execCommand: ->
        if @command == 'd' # display text
            Cursor.hide()
            Screen.println(@commandText)
            setTimeout((=> Typer.execNextCommand()), 50)
        else if @command == 'w' # wait with cursor flashing
            Cursor.show()
            setTimeout((=> Typer.execNextCommand()), parseInt(@commandText))
        else if @command == 't' # type as if user typing
            Cursor.show()
            if @commandPos < @commandText.length
                Screen.print(@commandText.charAt(@commandPos))
                @commandPos += 1
                #                delay = Math.round(Math.random()*200) + 50
                #                console.log({delay})
                setTimeout((=> Typer.execCommand()), 50)
            else
                Cursor.newLine()
                setTimeout((=> Typer.execNextCommand()), 800)
        else if @command == 'p' # pause with no cursor
            Cursor.hide()
            setTimeout((=> Typer.execNextCommand()), parseInt(@commandText))
        else if @command == 'x' # clear screen
            Screen.clear()
            setTimeout((=> Typer.execNextCommand()), 50)
        else if @command == 'c' # change text colour
            Screen.textColour = Colours[@commandText]
            setTimeout((=> Typer.execNextCommand()), 50)




window.Typer = Typer

class Sprite
    constructor: (@spriteData, @w, @h, @colours) ->
        @canvas = document.createElement('canvas')
        #        @canvas = document.getElementById('sprites')
        @imageW = Screen.pixelW * @w * 2
        @imageH = Screen.pixelH * @h
        @canvas.width = @imageW
        @canvas.height = @imageH * 2
        @ctx = @canvas.getContext("2d")
        @createCanvas()

    createCanvas: () ->
        x = 0
        y = 0
        x = x * Screen.pixelW
        y = y * Screen.pixelH

        for line in @spriteData.trim().split("\n")
            offset = 0

            for byteStr in line.match(/(..?)/g)
                byte = parseInt(byteStr, 16)
                for i in [0..3]
                    bits = byte & 0b11000000
                    colour =
                        if bits == 0b00000000
                            null
                        else if bits == 0b01000000
                            @colours[0]
                        else if bits == 0b10000000
                            @colours[1]
                        else if bits == 0b11000000
                            @colours[2]
                    if colour
                        @ctx.fillStyle = colour
                        @ctx.fillRect(x + offset * Screen.pixelW, y, Screen.pixelW * 2, Screen.pixelH)
                    offset += 2
                    byte = byte << 2
            y += Screen.pixelH
        true
        @ctx.save();
        @ctx.scale(-1, 1);
        @ctx.drawImage(@canvas, 0, @imageH, @imageW * -1, @imageH * 2)
        @ctx.restore();

    draw: (x, y, reversed) ->
# NOTE: x and y are device pixels, not game pixels
        sy = if reversed then @imageH else 0
        Screen.ctx.drawImage(@canvas, 0, sy, @imageW, @imageH, x, y, @imageW, @imageH)

    getImageData: (reversed) ->
        sy = if reversed then @imageH else 0
        @ctx.getImageData(0, sy, @imageW, @imageH).data

window.Sprite = Sprite
IntroPrg =
    run: (callback) ->
        Typer.display [
            'w:2000',
            't:LOAD "INTRO",8',
            'd:',
            'd:SEARCHING FOR INTRO',
            'p:1000',
            'd:LOADING',
            'p:2000',
            'd:READY.',
            'w:1000',
            't:?"@"',
            'x:',
            't:RUN',
            'c:BLACK',
            'd:Hello there',
            'c:GREEN',
            'd:Here\'s some green text',
            'c:PURPLE',
            'd:Purple text',
            'c:RED',
            'd:This is written in red',
            'c:CYAN',
            'd:and some in CYAN',
            'c:YELLOW',
            'd:How about yellow',
            'c:BLUE',
            'd:READY.',
            'w:1000',
        ],
            ->
#        Screen.clear()
                callback()



window.IntroPrg = IntroPrg
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

class Enemy
    constructor: ->
        @w = @sprite.imageW
        @h = @sprite.imageH
        @offsetX = @w / -2
        @offsetY = @h / -2
        @direction = if Math.random() > 0.5 then 1 else -1
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
        @y = @base + Math.sin(@x / 100) * 30
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
        @cooldown = Math.random() * 5
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


    generate: (levelNo) ->
        @levelEnded = false
        @items = []
        item.dead = true for item in @playerShots.pool
        item.dead = true for item in @enemyShots.pool
        item.dead = true for item in @particles.pool
        # TODO: generate different world for each level
        for i in [0..randInt(3)+4]
            @items.push new Building(randInt(@spawnWidth), @ground)
        for i in [0..(4 + levelNo)]
            @items.push new Radar(randInt(@spawnWidth), @ground)
        for i in [0.. (5 + 2 * levelNo)]
            @items.push new UFO(randInt(@spawnWidth), randInt(@blockToPixelH(11)) + @blockToPixelH(4.5))
        if levelNo > 2
            for i in [0.. (2 * levelNo)]
                @items.push new Mine(randInt(@spawnWidth), randInt(@blockToPixelH(11)) + @blockToPixelH(4.5))
        @guppies = levelNo > 1
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
                            @enemyDies(item, shot.x, shot.y)


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
        hitPoint = {x: hitPointX - @ship.x, y: hitPointY - @ship.y}
        @explodeSprite(@ship, hitPoint, 1)
        Game.respawnPlayer()

    enemyDies: (enemy, hitPointX, hitPointY) ->
        hitPoint = {x: hitPointX - enemy.x, y: hitPointY - enemy.y}
        @explodeSprite(enemy, hitPoint, 1)
        enemy.onExplode()
        enemy.dead = true
        Game.score += enemy.points
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
        origin = {x:0, y:0}
        #        console.log point, origin
        for y in [0...height] by Screen.pixelH
            for x in [0...width] by Screen.pixelW
                offset =  y * (width * 4) + x * 4
                r = imageData[offset]
                g = imageData[offset + 1]
                b = imageData[offset + 2]
                a = imageData[offset + 3]
                if a > 0
                    pixel = {x:x + gameItem.offsetX, y:y + gameItem.offsetY}
                    v1 = Vectors.angleDistBetweenPoints point, pixel
                    #                    v2 = Vectors.angleDistBetweenPoints origin, pixel
                    #                    v1.distance = 250
                    #                    v2 = Vectors.addVectors v1.angle, v1.distance, direction, 100
                    #                    v = Vectors.addVectors v1.angle, v1.distance + 100, v2.angle, v2.distance
                    #                    console.log(v)
                    pixel.x += gameItem.x
                    pixel.y += gameItem.y

                    @addParticle(pixel.x, pixel.y, v1.angle, v1.distance / 2 + 300, {r,g,b})


window.World = World

class Particle
    constructor: () ->
        @w = Screen.pixelW * 1.5
        @h = Screen.pixelH * 1.5
        @offsetX = @w / -2
        @offsetY = @h / -2
        @dead = true
        @maxLife = Math.random() + 2
        @colour = {}
        @drag = 0.985

    fire: (@x, @y, directionRad, speed, rgbValues) ->
        directionRad += Math.random() / 10 - 0.05
        speed *= 0.9 + Math.random() * 0.2
        @dead = false
        @offScreen = false
        @hSpeed = (Math.cos(directionRad) * speed)
        @vSpeed = (Math.sin(directionRad) * speed)
        @life = @maxLife
        @initColour(rgbValues)

    draw: (cameraOffsetX) ->
        Screen.ctx.fillStyle = @colour.hexString + @colour.alphaHex
        Screen.ctx.fillRect(@x + @offsetX - cameraOffsetX, @y + @offsetY, @w, @h)

    update: (delta) ->
        @hSpeed *= @drag
        @vSpeed *= @drag
        @x += @hSpeed * delta
        @y += @vSpeed * delta
        @life -= delta
        if @life <= 0
            @dead = true
        else
            ratio = @life / @maxLife
            if ratio < 0.5
                alpha = Math.round(ratio * 2 * 255).toString(16)
                alpha = '0' + alpha if alpha.length == 1
                @colour.alphaHex = alpha


    initColour: (rgbValues) ->
        r = rgbValues.r.toString(16)
        r = '0' + r if r.length == 1
        g = rgbValues.g.toString(16)
        g = '0' + g if g.length == 1
        b = rgbValues.b.toString(16)
        b = '0' + b if b.length == 1
        @colour.rgb = rgbValues
        @colour.hexString = '#'+r+g+b
        @colour.alphaHex = 'ff'


window.Particle = Particle

Vectors =
    originPoint: ->
        {x:0, y:0}

    degToRad: (deg) ->
        0.017453292519943295 * deg

    radToDeg: (rad) ->
        57.29577951308232 * rad

    rotatePoint: (point, angle) ->
        x= point[0]
        y= point[1]
        # convert point to polar
        length= Math.sqrt(x*x+y*y)
        angleR= Math.acos(x/length)
        if (y<0)
            angleR = 0 - angleR
        # add angle
        angleR += angle
        # convert back to cartesian
        x1= Math.cos(angleR)* length
        y1= Math.sin(angleR)* length
        return [x1,y1]

    rotatePath: (path, angle) ->
        path.map (p) => @rotatePoint(p, angle)

    addVectorToPoint: (point, angRad, length) ->
#    angRad = @degToRad(direction)
#    angRad = direction
        newPoint = x:0, y:0
        newPoint.x = point.x + (Math.cos(angRad) * length)
        newPoint.y = point.y + (Math.sin(angRad) * length)
        newPoint

    addVectors: (angle1, length1, angle2, length2) ->
        x1 = Math.cos(angle1) * length1
        y1 = Math.sin(angle1) * length1
        x2 = Math.cos(angle2) * length2
        y2 = Math.sin(angle2) * length2

        xR = x1 + x2
        yR = y1 + y2
        distance = Math.sqrt(xR*xR+yR*yR)
        return [0,0] if distance is 0

        angle = Math.acos(xR/distance)
        angle = 0 - angle if yR < 0

        return {angle, distance}


    angleDistBetweenPoints: (fromPoint, toPoint) ->
        return 0 if fromPoint is toPoint
        x = toPoint.x - fromPoint.x
        y = toPoint.y - fromPoint.y
        distance= Math.sqrt(x*x+y*y)
        angle= Math.acos(x/distance)
        if y < 0
            angle = 0 - angle
        {angle, distance}

    distBetweenPoints: (fromPoint, toPoint) ->
        return 0 if fromPoint is toPoint
        x = toPoint.x - fromPoint.x
        y = toPoint.y - fromPoint.y
        Math.sqrt(x*x+y*y)

    shapesWithinReach: (shapeA, shapeB) ->
        Vectors.distBetweenPoints(shapeA.position, shapeB.position) < shapeA.reach + shapeB.reach

    shapeBounds: (paths) ->
        return {minX:0, minY:0, maxX:0, maxY:0} if paths.length is 0 or paths[0].length is 0 or paths[0][0].length is 0
        minX = maxX = paths[0][0][1]
        minY = maxY = paths[0][0][1]
        for path in paths
            for point in path
                minX = point[0] if point[0] < minX
                maxX = point[0] if point[0] > maxX
                minY = point[1] if point[1] < minY
                maxY = point[1] if point[1] > maxY
        {minX, maxX, minY, maxY}

    shapeCentre: (paths) ->
        bounds = @shapeBounds(paths)
        {x: (bounds.minX + bounds.maxX)/2, y:(bounds.minY + bounds.maxY)/2}

    distFromOrigin: (x, y) ->
        Math.sqrt(x * x + y * y)

    movePathOrigin: (paths, originX, originY) ->
        for path in paths
            for point in path
                unless point.length is 0
                    point[0] -= originX
                    point[1] -= originY

    centrePath: (paths) ->
        centre = Vectors.shapeCentre(paths)
        Vectors.movePathOrigin(paths, centre.x, centre.y)

    centrePathH: (paths) ->
        centre = Vectors.shapeCentre(paths)
        Vectors.movePathOrigin(paths, centre.x, 0)

    centrePathV: (paths) ->
        centre = Vectors.shapeCentre(paths)
        Vectors.movePathOrigin(paths, 0, centre.y)


window.Vectors = Vectors

class ItemPool
    constructor: (itemClass, poolSize) ->
        @pool = []
        for i in [0..poolSize]
            @pool.push new itemClass()
        @itemIndex = 0

    getNextItem: ->
        item = @pool[@itemIndex]
        @itemIndex += 1
        if @itemIndex == @pool.length
            @itemIndex = 0
        return item


window.ItemPool = ItemPool

