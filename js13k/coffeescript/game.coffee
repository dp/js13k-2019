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

        if @state != @lastState
            console.log 'Changed state to ', @state
            @lastState = @state

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
