let charBytes = []
for (let i=0; i< 128; i++) {
    // fill with checkerboard pattern so I can easily see if I've missed one
    charBytes[i] = [178,85,178,85,178,85,178,85]
}


const astroDigits = `
7e4e4e4242427e00
1818080818183c00
7e42027e60627e00
7e02023e06067e00
4444447c0c0c0c00
7e42407e06467e00
7e42407e62627e00
7c44040c0c0c0c00
3c24247e62627e00
7e42427e06060600
`

const guppie = `
03c0
f0f0
70f0
f3fc
33ac
3faa
3faa
33ac
f3fc
70f0
f0f0
03c0
`
const mine = `
0300
0300
0080
0080
0300
0300
2173
2173
cd48
cd48
00c0
00c0
0200
0200
00c0
00c0
`

const building = `
0200
0200
0200
0a80
2320
2320
2320
2fe0
2320
2320
2320
2fe0
2320
2320
2320
bff8
8cc8
8cc8
8cc8
bff8
8cc8
8cc8
8cc8
bff8
8cc8
8cc8
8cc8
bff8
8008
8548
8448
aaa8
`

const ship = `
ff000000
fc000000
3f000000
0fc00000
3ff00000
2aa95000
eaaa5400
eaaa95b0
eaaaaabc
efeaaaaf
3faaaabc
fc000000
ff000000
`
const radar = `
0140
0140
0140
0140
aaaa
2aa8
0aa0
03c0
03c0
3ffc
2ff8
2008
2008
8822
8822
a82a
`
const ufo = `
0280
0eb0
2aa8
8296
8296
8296
8296
2aa8
0be0
`
const playerShot = `
0000
01e8
007a
01e8
`
const enemyShot = `
01
01
`

function addChars(startPos, charData) {
    let chars = charData.trim()
        .split(/\n/)
        .map(bytes => {
            return bytes.replace(/(\w{2})/g,'$1 ')
                .trim()
                .split(' ')
                .map(byte => {
                    return parseInt(byte, 16)
                })
        })
    charBytes.splice(startPos, chars.length, ...chars)
}

addChars(32, `
0000000000000000
0808080800000800
2424240000000000
24247e247e242400
080808082a1c0800
00000804fe040800
304848304a443a00
0408100000000000
0408101010080400
2010080808102000
082a1c3e1c2a0800
0008083e08080000
0000000000080810
0000007e00000000
0000000000181800
367f7f7f3e1c0800
3c42465a62423c00
0818280808083e00
3c42020c30407e00
3c42021c02423c00
040c14247e040400
7e40780402443800
1c20407c42423c00
7e42040810101000
3c42423c42423c00
3c42423e02043800
0000080000080000
000000ff00000000
0e18306030180e00
00007e007e000000
70180c060c187000
3c42020c10001000
c9808080c1e3f7ff
1824427e42424200
7c22223c22227c00
1c22404040221c00
7824222222247800
7e40407840407e00
7e40407840404000
1c22404e42221c00
4242427e42424200
1c08080808081c00
0e04040404443800
4244487048444200
4040404040407e00
42665a5a42424200
4262524a46424200
1824424242241800
7c42427c40404000
182442424a241a00
7c42427c48444200
3c42403c02423c00
3e08080808080800
4242424242423c00
4242422424181800
4242425a5a664200
4242241824424200
2222221c08080800
7e02041820407e00
3c20202020203c00
0c10103c10706e00
3c04040404043c00
081c2a0808080800
000010207f201000
1c224a564c201e00
000038043c443a00
40405c6242625c00
00003c4240423c00
02023a4642463a00
00003c427e403c00
0c12107c10101000
00003a46463a023c
40405c6242424200
0800180808081c00
04000c0404044438
4040444850684400
1808080808081c00
0000764949494900
00005c6242424200
00003c4242423c00
00005c62625c4040
00003a46463a0202
00005c6240404000
00003e403c027c00
10107c1010120c00
0000424242463a00
0000424242241800
0000414949493600
0000422418244200
00004242463a023c
00007e0418207e00
    `)

function runIntro() {
    IntroPrg.run(function(){
        console.log('All done!')
    })
}

function initScreen () {
    let w = window.innerWidth
    let h = window.innerHeight
    let pixel = null
    if (w >= 1600 && h >= 920)
        pixel = [8,5]
    else if (w >= 1400 && h >= 920)
        pixel = [7,5]
    else if (w >= 1200 && h >= 736)
        pixel = [6,4]
    else if (w >= 1000 && h >= 552)
        pixel = [5,3]
    else if (w >= 800 && h >= 552)
        pixel = [4,3]
    else if (w >= 600 && h >= 368)
        pixel = [3,2]
    else
        pixel = [2,1]
    Screen.init(pixel[0], pixel[1])
}

function initSprites() {
    let colours = [Colours.BLUE, Colours.YELLOW, Colours.RED]
    window.sprites = {
        seeker: new Sprite(guppie, 8, 12, colours),
        mine: new Sprite(mine, 8, 16, colours),
        building: new Sprite(building, 7, 32, colours),
        radar: new Sprite(radar, 8, 16, colours),
        ufo: new Sprite(ufo, 8, 9, colours),
        ship: new Sprite(ship, 16, 13, colours),
        playerShot: new Sprite(playerShot, 8, 4, colours), //[Colours.BLUE, Colours.PURPLE, Colours.CYAN])
        enemyShot: new Sprite(enemyShot, 4, 2, [Colours.CYAN]) //[Colours.BLUE, Colours.PURPLE, Colours.CYAN])
    }
}
function randInt(range) {
    return Math.floor(Math.random() * range)
}

function buildHitbox(offsetX, offsetY, left, top, right, bottom) {
    // params in vic pixels from top left of item
    // need to return values from offset in device pixels
    return {
        left: offsetX + left * Screen.pixelW,
        right: offsetX + right * Screen.pixelW,
        top: offsetY + top * Screen.pixelH,
        bottom: offsetY + bottom * Screen.pixelH
    }
}

// function pointInHitbox (hitbox, pointX, pointY) {
//     // remember @offset is negative
//     pointX > @x + @offsetX && pointX < @x - @offsetX &&
//     pointY > @y + @offsetY && pointY < @y - @offsetY
// }


function test() {
    initScreen()
    Typer.display([
        'd:**** CBM BASIC V2 ***',
        'd:',
        'd:13312 BYTES FREE',
        'd:',
        'd:READY.',
        'w:200',

        // 'w:2000',
        // 't:LOAD "GAME",8',
        // 'd:',
        // 'd:SEARCHING FOR GAME',
        // 'p:1000',
        // 'd:LOADING',
        // 'p:2000',
        // 'd:READY.',
        // 'w:1000',
        // 't:?"@"',
        // 'x:',
        // 't:RUN',
        // 'p:500',
        // 'c:BLACK',

        ],
        function(){
            initSprites()
            Game.run()
    })
}
