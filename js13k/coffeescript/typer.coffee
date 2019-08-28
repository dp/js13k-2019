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

