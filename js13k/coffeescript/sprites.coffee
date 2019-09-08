guppie = '''
...##
##..##
x#..##
##.####
.#.#--#
.###----
.###----
.#.#--#
##.####
x#..##
##..##
...##
'''

mine = '''
...#
...#
....-
....-
...#
...#
.-.xx#.#
.-.xx#.#
#.#xx.-
#.#xx.-
....#
....#
...-
...-
....#
....#
'''

building = '''
...-
...-
...-
..---
.-.#.-
.-.#.-
.-.#.-
.-###-
.-.#.-
.-.#.-
.-.#.-
.-###-
.-.#.-
.-.#.-
.-.#.-
-#####-
-.#.#.-
-.#.#.-
-.#.#.-
-#####-
-.#.#.-
-.#.#.-
-.#.#.-
-#####-
-.#.#.-
-.#.#.-
-.#.#.-
-#####-
-.....-
-.xxx.-
-.x.x.-
-------
'''

ship = '''
####
###
.###
..###
.#####
.------xxx
#-------xxx
#--------xxx-#
#------------##
#-###---------##
.###---------##
###
####
'''

radar = '''
...xx
...xx
...xx
...xx
--------
.------
..----
...##
...##
.######
.-####-
.-....-
.-....-
-.-..-.-
-.-..-.-
---..---
'''

ufo = '''
...--
..#--#
.------
-..--xx-
-..--xx-
-..--xx-
-..--xx-
.------
..-##-
'''

shot = '''
.....x#
-..---x#
..-.--x#
.....x#
'''

snake = '''
...##
.#-##-
.#----
.#-----
...----
...-xx-
...xxx--
..xxxxx-
..xxxxx-
...xxx--
...-xx-
...----
.#-----
.#----
.#-##-
...##
'''

convert = (spriteChars, width) ->
    lines = spriteChars.split("\n")
    text = ''
    for line in lines
        line = (line + '...................').slice(0,width)
        binString = ''
        for char in line
            binString += if char == '.'
                            '00'
                        else if char == '#'
                            '11'
                        else if char == '-'
                            '10'
                        else if char == 'x'
                            '01'
                        else
                            'xx'
        dec = parseInt(binString, 2)
        hex = ('000000' + dec.toString(16)).slice(-4)
        text += hex + "\n"
    console.log(text)

#convert(guppie, 8)
#console.log()
#convert(mine, 8)
convert(snake, 8)

