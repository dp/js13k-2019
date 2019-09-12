guppie = '''
...##
-#.x##
###x##
x######
.x##--x
..#x----
..#x----
.x##--x
x######
###x##
-#.x##
...##
'''

mine = '''
..#.#
..#.#
...-
...-
#.xxx.#
#.xxx.#
.-x-x-
.-x-x-
#.xxx.#
#.xxx.#
...-
...-
..#.#
..#.#
'''

building = '''
..---
..-.-
..-.-
..-#-
.-#.#-
.-#.#-
.-#.#-
.-###-
.-#.#-
.-#.#-
.-#.#-
-#####-
-#.#.#-
-#.#.#-
-#.#.#-
-#####-
-#.#.#-
-#.#.#-
-#.#.#-
-#####-
-#.#.#-
-#.#.#-
-#.#.#-
-#####-
-#.#.#-
-#.#.#-
-#.#.#-
-#####-
-##x##-
-##x##-
-##x##-
-#xxx#-
'''

ship = '''
...#####
...###
..###
..###
.####
.#####-xxx
#------xxxx
#------xxxxx-#
#-------xxx--##
#-###---------##
.####----######
..####....##
...#####...##
'''

#ship = '''
#####
####
#.###
#..###
#.#####
#.------xxx
##-------xxx
##--------xxx-#
##------------##
##-###---------##
#.###---------##
####
#####
#'''

radar = '''
...##
...##
...##
...##
--------
.------
..----
...--
..x..x
.x....x
..x..x
...xx
..####
.######
.######
.xxxxxx
'''

ufo = '''
...--
..#--x
.------
-xx--##-
-xxx###-
-xxx###-
-xx--##-
.------
..#--x
...--
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

#
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

convert(guppie, 8)
#console.log()
#convert(mine, 8)
#convert(building, 8)
#convert(radar, 8)
#convert(ufo, 8)
#convert(ship, 16)

