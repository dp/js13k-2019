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