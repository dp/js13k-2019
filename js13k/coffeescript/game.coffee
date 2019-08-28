GameStates =
    PRE_LAUNCH: 0
    TITLE_SCREEN: 1
    PLAYING_IN_PLAY: 2
    PLAYING_WARPING: 3
    START_OF_LEVEL: 4
    PLAYING_BETWEEN_LIVES: 5
    GAME_OVER: 6

Game =
    state: GameStates.PRE_LAUNCH

    run: ->
        @ctx = Screen.ctx
        @canvas = Screen.canvas
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

        if @state == GameStates.TITLE_SCREEN
            if keysDown.fire
                @startGame()

        else if @state == GameStates.PLAYING || @state == GameStates.PLAYING_WARPING || @state == GameStates.GAME_OVER
            @world.update(delta)
            @draw()

    draw: ->
        if @state == GameStates.PLAYING_WARPING
            Screen.screenColour = Colours.PURPLE
            Screen.clear()
            Screen.textColour = Colours.WHITE
            Screen.printAt 5, 8, 'LEVEL 1 CLEARED'
            Screen.printAt 8, 10, 'WARPING ...'
            Screen.printAt 2, 14, 'Sorry, that\'s all I\'ve programmed for the moment'
            Screen.textColour = Colours.BLUE
        else if @state == GameStates.GAME_OVER
            Screen.textColour = Colours.WHITE
            Screen.printAt 8, 8, 'GAME OVER'
            Screen.printAt 4, 10, 'Haven\'t programmed    ability to restart game  yet, so you\'re stuck on  this screen :)'
        else
            @ctx.fillStyle = Colours.BLACK
            @ctx.fillRect(0, 0, @canvas.width, @canvas.height)
            Screen.textColour = Colours.WHITE

        Screen.printAt 1, 2, ''+@score
        Screen.printAt 12, 2, ''+@level
        for i in [1..@livesLeft]
            Screen.printAt 24 - i, 2, '/' # prints a heart character
        @world.draw()

    startGame: ->
        @state = GameStates.PLAYING
        Screen.clear()
        Screen.printAt 8, 4, "Playing ..."
        @score = 0
        @livesLeft = 4
        @level = 1
        @ship = new Ship()
        @world = new World(1, @ship)

    warpToNextWorld: ->
        @state = GameStates.PLAYING_WARPING

    hLine: (row) ->
        Screen.printAt 0, row, ';;;;;;;;;;;;;;;;;;;;;;;;;'


    showTitleScreen: ->
        @state = GameStates.TITLE_SCREEN
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
