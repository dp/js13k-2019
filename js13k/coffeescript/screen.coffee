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