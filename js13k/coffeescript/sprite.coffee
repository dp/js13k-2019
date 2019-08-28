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
