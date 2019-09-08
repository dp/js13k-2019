(function(){var Building,Colours,Cursor,Enemy,EnemyShot,Game,GameStates,Guppie,IntroPrg,ItemPool,Mine,Particle,PlayerShot,Radar,Screen,Ship,Sprite,Typer,UFO,Vectors,World,extend=function(child,parent){for(var key in parent){if(hasProp.call(parent,key)){child[key]=parent[key]}}function ctor(){this.constructor=child}ctor.prototype=parent.prototype;child.prototype=new ctor();child.__super__=parent.prototype;return child},hasProp={}.hasOwnProperty;Colours={BLACK:'#000000',WHITE:'#ffffff',RED:'#e32d2d',CYAN:'#2de3e3',PURPLE:'#b31de3',GREEN:'#2dc32d',BLUE:'#2d2de3',YELLOW:'#e3e32d'};Cursor={x:0,y:0,visible:false,blinkTimer:null,blinkStateOn:true,show:function(){this.blinkTimer||(this.blinkTimer=setInterval(Cursor.blink,500));this.visible=true;this.blinkStateOn=true;return this.draw()},hide:function(){clearInterval(this.blinkTimer);this.blinkTimer=null;this.blinkStateOn=false;this.draw();return this.visible=false},blink:function(){Cursor.blinkStateOn=!Cursor.blinkStateOn;return Cursor.draw()},draw:function(){var colour;if(this.visible){colour=this.blinkStateOn?Screen.textColour:Screen.screenColour;return Screen.drawCharRect(Cursor.x,Cursor.y,colour)}},moveTo:function(newX,newY){if(this.visible){Screen.drawCharRect(Cursor.x,Cursor.y,Screen.screenColour)}Cursor.x=newX;Cursor.y=newY;return this.draw()},newLine:function(){return this.moveTo(0,Cursor.y+1)}};Screen={screenColour:Colours.WHITE,textColour:Colours.BLUE,colour2:Colours.YELLOW,colour3:Colours.RED,columnsWide:22,rowsHigh:23,pixelW:5,pixelH:3,init:function(pixelW,pixelH){this.pixelW=pixelW;this.pixelH=pixelH;this.pixelD=Math.sqrt(this.pixelW*this.pixelW+this.pixelH*this.pixelH);this.canvas=document.getElementById('game');this.ctx=this.canvas.getContext("2d");this.setSize(this.columnsWide,this.rowsHigh);return this.clear()},clear:function(){this.ctx.fillStyle=this.screenColour;this.ctx.fillRect(0,0,this.canvas.width,this.canvas.height);Cursor.x=0;return Cursor.y=0},setBorder:function(colour){return document.body.style.backgroundColor=colour},setSize:function(newCols,newRows){this.columnsWide=newCols;this.rowsHigh=newRows;this.canvas.width=this.columnsWide*8*this.pixelW;return this.canvas.height=this.rowsHigh*8*this.pixelH},setCursor:function(col,row){Cursor.x=col;return Cursor.y=row},moveCursor:function(){var x,y;x=Cursor.x+1;y=Cursor.y;if(x===this.columnsWide){x=0;y=Cursor.y+1;if(y===this.rowsHigh){y=0}}return Cursor.moveTo(x,y)},drawCharRect:function(x,y,colour){this.ctx.fillStyle=colour;return this.ctx.fillRect(x*8*this.pixelW,y*8*this.pixelH,8*Screen.pixelW,8*Screen.pixelH)},drawCharAtCursor:function(charCode){var char,x,y;char=charBytes[charCode];x=Cursor.x*8*this.pixelW;y=Cursor.y*8*this.pixelH;this.moveCursor();this.ctx.fillStyle=this.textColour;char.forEach(function(byte){var i;i=0;while(i<8){if(byte&Math.pow(2,7-i)){Screen.ctx.fillRect(x+i*Screen.pixelW,y,Screen.pixelW,Screen.pixelH)}i+=1}return y+=Screen.pixelH});return true},print:function(text){var i,j,ref,results;results=[];for(i=j=0,ref=text.length;0<=ref?j<ref:j>ref;i=0<=ref? ++j: --j){results.push(this.drawCharAtCursor(this.asciiToVic(text.charCodeAt(i))))}return results},println:function(text){this.print(text);return Cursor.newLine()},printAt:function(col,row,text){Cursor.moveTo(col,row);return this.print(text)},asciiToVic:function(ascii){return ascii},drawSprite:function(x,y,sprite){var bits,byte,byteStr,colour,i,j,k,l,len,len1,line,offset,ref,ref1;x=x*this.pixelW;y=y*this.pixelH;ref=sprite.trim().split("\n");for(j=0,len=ref.length;j<len;j+=1){line=ref[j];offset=0;ref1=line.match(/(..?)/g);for(k=0,len1=ref1.length;k<len1;k+=1){byteStr=ref1[k];byte=parseInt(byteStr,16);for(i=l=0;l<=3;i= ++l){bits=byte&0xc0;colour=bits===0x0?null:bits===0x40?this.textColour:bits===0x80?this.colour2:bits===0xc0?this.colour3:void 0;if(colour){this.ctx.fillStyle=colour;this.ctx.fillRect(x+offset*Screen.pixelW,y,Screen.pixelW*2,Screen.pixelH)}offset+=2;byte=byte<<2}}y+=Screen.pixelH}return true}};window.Screen=Screen;window.Colours=Colours;window.Cursor=Cursor;GameStates={PRE_LAUNCH:'PRE_LAUNCH',TITLE_SCREEN:'TITLE_SCREEN',PLAYING_IN_PLAY:'PLAYING_IN_PLAY',PLAYING_WARPING:'PLAYING_WARPING',START_OF_LEVEL:'START_OF_LEVEL',PLAYING_SPAWNING:'PLAYING_SPAWNING',GAME_OVER:'GAME_OVER'};Game={state:GameStates.PRE_LAUNCH,run:function(){this.ctx=Screen.ctx;this.canvas=Screen.canvas;this.cooldown=0;Screen.setSize(25,23);Screen.screenColour=Colours.BLACK;Screen.textColour=Colours.WHITE;Screen.setBorder(Colours.BLUE);Cursor.hide();addChars(48,astroDigits);this.showTitleScreen();return requestAnimationFrame(update)},update:function(timestamp){var delta;if(this.lastTimestamp){delta=(timestamp-this.lastTimestamp)/1000}else{delta=0}this.lastTimestamp=timestamp;this.cooldown-=delta;if(this.state===GameStates.TITLE_SCREEN){if(keysDown.fire&&this.cooldown<=0){this.startGame()}}else{if(this.state===GameStates.GAME_OVER){if(keysDown.fire&&this.cooldown<=0){this.state=GameStates.TITLE_SCREEN;this.cooldown=1;this.showTitleScreen()}}else if(this.state===GameStates.PLAYING_SPAWNING){if(this.cooldown<0){this.state=GameStates.PLAYING_IN_PLAY;this.ship.invulnerable=false}else if(this.cooldown<2){this.ship.dead=false;this.ship.autopilot=false;this.ship.invulnerable=true}}else if(this.state===GameStates.PLAYING_WARPING){if(this.cooldown<0){this.state=GameStates.PLAYING_SPAWNING;this.ship.autopilot=false;this.ship.invulnerable=true;this.ship.warping=false;this.cooldown=2}else if(this.cooldown<2&&this.world.levelEnded){this.level+=1;this.world.generate(this.level)}}}if(this.state!==GameStates.TITLE_SCREEN){this.world.update(delta);return this.draw()}},draw:function(){var i,j,levelText,ref;if(this.state===GameStates.PLAYING_WARPING){Screen.screenColour=Colours.PURPLE;Screen.clear();Screen.textColour=Colours.WHITE;levelText=this.world.levelEnded?this.level:this.level-1;Screen.printAt(5,8,"LEVEL "+levelText+" CLEARED");Screen.printAt(8,10,'WARPING ...');Screen.textColour=Colours.BLUE}else{this.ctx.fillStyle=Colours.BLACK;this.ctx.fillRect(0,0,this.canvas.width,this.canvas.height);Screen.textColour=Colours.WHITE}Screen.printAt(1,2,''+this.score);Screen.printAt(12,2,''+this.level);if(this.livesLeft>0){for(i=j=1,ref=this.livesLeft;1<=ref?j<=ref:j>=ref;i=1<=ref? ++j: --j){Screen.printAt(24-i,2,'/')}}this.world.draw();if(this.state===GameStates.GAME_OVER){Screen.textColour=Colours.WHITE;Screen.printAt(8,8,'GAME OVER');if(this.cooldown<0){return Screen.printAt(7,10,'Press  FIRE')}}},startGame:function(){this.state=GameStates.PLAYING_SPAWNING;Screen.clear();Screen.printAt(8,4,"Playing ...");this.score=0;this.livesLeft=4;this.level=1;this.ship=new Ship();this.world=new World(1,this.ship);return this.cooldown=2},warpToNextWorld:function(){this.state=GameStates.PLAYING_WARPING;this.cooldown=5;this.ship.warping=true;return this.world.levelEnded=true},endGame:function(){this.state=GameStates.GAME_OVER;return this.cooldown=3},respawnPlayer:function(){this.ship.dead=true;this.ship.autopilot=true;if(this.livesLeft===0){return this.endGame()}else{this.livesLeft-=1;this.ship.y=8*12*Screen.pixelH;this.state=GameStates.PLAYING_SPAWNING;return this.cooldown=3}},hLine:function(row){return Screen.printAt(0,row,';;;;;;;;;;;;;;;;;;;;;;;;;')},showTitleScreen:function(){this.state=GameStates.TITLE_SCREEN;Screen.screenColour=Colours.BLACK;Screen.clear();Screen.printAt(8,4,"ASTROBLITZ");Screen.printAt(0,6,"(C)1982 CREATIVE SOFTWARE");this.hLine(7);Screen.printAt(15,9,"50");Screen.printAt(15,12,"50");Screen.printAt(15,15,"100");Screen.printAt(15,18,"150");Screen.printAt(1,10,"MOVE");Screen.printAt(1,12,"OR");Screen.printAt(1,16,"FIRE");this.hLine(20);this.hLine(22);Screen.textColour=Colours.YELLOW;Screen.printAt(3,21,'PRESS SPACE TO START');Screen.textColour=Colours.CYAN;Screen.printAt(1,11,"^ _ $ %");Screen.printAt(1,13,"W A S D");Screen.printAt(1,17,"SPACE");Screen.textColour=Colours.BLUE;Screen.drawSprite(96,71,ufo);Screen.drawSprite(96,88,radar);Screen.drawSprite(96,112,mine);return Screen.drawSprite(96,140,guppie)}};window.update=function(timestamp){Game.update(timestamp);if(window.paused){console.log('Game is paused')}else{window.requestAnimationFrame(update)}return true};window.keysDown={left:false,right:false,up:false,down:false,fire:false};window.paused=false;window.keyToggled=function(keyCode,isPressed){if(keyCode===32){window.keysDown.fire=isPressed}if(keyCode===38||keyCode===90||keyCode===87){window.keysDown.up=isPressed}if(keyCode===39||keyCode===68){window.keysDown.right=isPressed}if(keyCode===40||keyCode===83){window.keysDown.down=isPressed}if(keyCode===37||keyCode===65||keyCode===81){window.keysDown.left=isPressed}if(keyCode===66){window.paused=isPressed;return console.log('Paused',window.paused)}};window.onkeydown=function(e){return keyToggled(e.keyCode,true)};window.onkeyup=function(e){return keyToggled(e.keyCode,false)};window.Game=Game;window.GameStates=GameStates;Typer={command:null,commandPos:0,display:function(commands,callback1){this.commands=commands;this.callback=callback1;return this.execNextCommand()},execNextCommand:function(){var command;if(this.commands.length===0){if(typeof this.callback==="function"){this.callback()}return}command=this.commands.shift().split(':');this.commandText=command[1];this.command=command[0];this.commandPos=0;return this.execCommand()},execCommand:function(){if(this.command==='d'){Cursor.hide();Screen.println(this.commandText);return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),50)}else if(this.command==='w'){Cursor.show();return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),parseInt(this.commandText))}else if(this.command==='t'){Cursor.show();if(this.commandPos<this.commandText.length){Screen.print(this.commandText.charAt(this.commandPos));this.commandPos+=1;return setTimeout(((function(_this){return function(){return Typer.execCommand()}})(this)),50)}else{Cursor.newLine();return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),800)}}else if(this.command==='p'){Cursor.hide();return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),parseInt(this.commandText))}else if(this.command==='x'){Screen.clear();return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),50)}else if(this.command==='c'){Screen.textColour=Colours[this.commandText];return setTimeout(((function(_this){return function(){return Typer.execNextCommand()}})(this)),50)}}};window.Typer=Typer;Sprite=(function(){function Sprite(spriteData,w,h,colours){this.spriteData=spriteData;this.w=w;this.h=h;this.colours=colours;this.canvas=document.createElement('canvas');this.imageW=Screen.pixelW*this.w*2;this.imageH=Screen.pixelH*this.h;this.canvas.width=this.imageW;this.canvas.height=this.imageH*2;this.ctx=this.canvas.getContext("2d");this.createCanvas()}Sprite.prototype.createCanvas=function(){var bits,byte,byteStr,colour,i,j,k,l,len,len1,line,offset,ref,ref1,x,y;x=0;y=0;x=x*Screen.pixelW;y=y*Screen.pixelH;ref=this.spriteData.trim().split("\n");for(j=0,len=ref.length;j<len;j+=1){line=ref[j];offset=0;ref1=line.match(/(..?)/g);for(k=0,len1=ref1.length;k<len1;k+=1){byteStr=ref1[k];byte=parseInt(byteStr,16);for(i=l=0;l<=3;i= ++l){bits=byte&0xc0;colour=bits===0x0?null:bits===0x40?this.colours[0]:bits===0x80?this.colours[1]:bits===0xc0?this.colours[2]:void 0;if(colour){this.ctx.fillStyle=colour;this.ctx.fillRect(x+offset*Screen.pixelW,y,Screen.pixelW*2,Screen.pixelH)}offset+=2;byte=byte<<2}}y+=Screen.pixelH}true;this.ctx.save();this.ctx.scale(-1,1);this.ctx.drawImage(this.canvas,0,this.imageH,this.imageW*-1,this.imageH*2);return this.ctx.restore()};Sprite.prototype.draw=function(x,y,reversed){var sy;sy=reversed?this.imageH:0;return Screen.ctx.drawImage(this.canvas,0,sy,this.imageW,this.imageH,x,y,this.imageW,this.imageH)};Sprite.prototype.getImageData=function(reversed){var sy;sy=reversed?this.imageH:0;return this.ctx.getImageData(0,sy,this.imageW,this.imageH).data};return Sprite})();window.Sprite=Sprite;IntroPrg={run:function(callback){return Typer.display(['w:2000','t:LOAD "INTRO",8','d:','d:SEARCHING FOR INTRO','p:1000','d:LOADING','p:2000','d:READY.','w:1000','t:?"@"','x:','t:RUN','c:BLACK','d:Hello there','c:GREEN','d:Here\'s some green text','c:PURPLE','d:Purple text','c:RED','d:This is written in red','c:CYAN','d:and some in CYAN','c:YELLOW','d:How about yellow','c:BLUE','d:READY.','w:1000'],function(){return callback()})}};window.IntroPrg=IntroPrg;Ship=(function(){function Ship(){this.sprite=sprites.ship;this.w=this.sprite.imageW;this.h=this.sprite.imageH;this.offsetX=this.w/-2;this.offsetY=this.h/-2;this.x=100;this.y=100;this.facingLeft=false;this.vSpeed=100*Screen.pixelH;this.hSpeed=150*Screen.pixelW;this.minY=18*Screen.pixelH;this.maxY=165*Screen.pixelH;this.offScreen=false;this.dead=false;this.autopilot=false;this.invulnerable=false;this.warping=false;this.cooldown=0.3;this.hitbox=buildHitbox(this.offsetX,this.offsetY,1,4,30,12)}Ship.prototype.update=function(delta){if(this.cooldown>0){this.cooldown-=delta;if(this.cooldown<0){return this.cooldown=0}}};Ship.prototype.draw=function(cameraOffsetX){return this.sprite.draw(this.x+this.offsetX-cameraOffsetX,this.y+this.offsetY,this.facingLeft)};Ship.prototype.moveV=function(delta,direction){var target;if(this.warping){target=Game.world.blockToPixelH(13);if(Math.abs(target-this.y)<2){return this.y=target}else if(this.y>target){return this.y-=1}else{return this.y+=1}}else{this.y+=direction*delta*this.vSpeed;if(this.y<this.minY){this.y=this.minY}if(this.y>this.maxY){return this.y=this.maxY}}};Ship.prototype.moveH=function(delta,direction){if(this.warping){this.x+=delta*this.hSpeed*5}else{this.x+=direction*delta*this.hSpeed}return this.facingLeft=direction<0};Ship.prototype.fireShot=function(){var shotOffset,shotSpeed;if(this.warping){return}if(this.cooldown>0){return}shotSpeed=200*Screen.pixelW;shotOffset=14*Screen.pixelW;if(this.facingLeft){shotSpeed*=-1;shotOffset*=-1}Game.world.getNextPlayerShot().fire(this.x+shotOffset,this.y+2*Screen.pixelH,shotSpeed);return this.cooldown=0.2};return Ship})();PlayerShot=(function(){function PlayerShot(){this.sprite=sprites.playerShot;this.w=this.sprite.imageW;this.h=this.sprite.imageH;this.offsetX=this.w/-2;this.offsetY=this.h/-2;this.dead=true;this.hitbox=buildHitbox(this.offsetX,this.offsetY,0,-1,14,6)}PlayerShot.prototype.fire=function(x3,y3,hSpeed){this.x=x3;this.y=y3;this.hSpeed=hSpeed;this.dead=false;this.offScreen=false;return this.facingLeft=this.hSpeed<0};PlayerShot.prototype.draw=function(cameraOffsetX){return this.sprite.draw(this.x+this.offsetX-cameraOffsetX,this.y+this.offsetY,this.facingLeft)};PlayerShot.prototype.update=function(delta){this.x+=this.hSpeed*delta;if(this.offScreen){return this.dead=true}};return PlayerShot})();window.Ship=Ship;window.PlayerShot=PlayerShot;Enemy=(function(){function Enemy(){this.w=this.sprite.imageW;this.h=this.sprite.imageH;this.offsetX=this.w/-2;this.offsetY=this.h/-2;this.direction=Math.random()>0.5?1:-1;this.facingLeft=this.direction<0;this.canBeDestroyed=true}Enemy.prototype.draw=function(cameraOffsetX){return this.sprite.draw(this.x+this.offsetX-cameraOffsetX,this.y+this.offsetY,this.facingLeft)};Enemy.prototype.update=function(delta){return true};Enemy.prototype.onExplode=function(){return true};return Enemy})();EnemyShot=(function(){function EnemyShot(){this.sprite=sprites.enemyShot;this.w=this.sprite.imageW;this.h=this.sprite.imageH;this.offsetX=this.w/-2;this.offsetY=this.h/-2;this.dead=true}EnemyShot.prototype.fire=function(x3,y3,speed,directionRad){this.x=x3;this.y=y3;this.dead=false;this.offScreen=false;this.hSpeed=Math.cos(directionRad)*speed;return this.vSpeed=Math.sin(directionRad)*speed};EnemyShot.prototype.draw=function(cameraOffsetX){return this.sprite.draw(this.x+this.offsetX-cameraOffsetX,this.y+this.offsetY,false)};EnemyShot.prototype.update=function(delta){this.x+=this.hSpeed*delta;this.y+=this.vSpeed*delta;if(this.offScreen){return this.dead=true}};return EnemyShot})();window.Enemy=Enemy;window.EnemyShot=EnemyShot;UFO=(function(superClass){extend(UFO,superClass);function UFO(x3,base){this.x=x3;this.base=base;this.sprite=sprites.ufo;this.y=this.base;this.vSpeed=200*Screen.pixelH;this.hSpeed=30*Screen.pixelW;UFO.__super__.constructor.apply(this,arguments);this.points=50;this.hitbox=buildHitbox(this.offsetX,this.offsetY,1,2,14,6)}UFO.prototype.update=function(delta){this.x+=this.direction*this.hSpeed*delta;this.y=this.base+Math.sin(this.x/100)*30;if(!this.offScreen&&Math.random()>0.99){return this.fire()}};UFO.prototype.fire=function(){var direction,shotOffset,shotSpeed;shotOffset=Screen.pixelW*4;shotSpeed=20*Screen.pixelD;direction=Math.random()*Math.PI*2;return Game.world.getNextEnemyShot().fire(this.x+shotOffset,this.y+2*Screen.pixelH,shotSpeed,direction)};return UFO})(Enemy);Guppie=(function(superClass){extend(Guppie,superClass);function Guppie(x3){this.x=x3;this.sprite=sprites.seeker;this.y=100;this.vSpeed=15*Screen.pixelH;this.hSpeed=40*Screen.pixelW;Guppie.__super__.constructor.apply(this,arguments);this.points=150;this.hitbox=buildHitbox(this.offsetX,this.offsetY,2,2,12,8)}Guppie.prototype.setRandomTargetDelta=function(){this.targetDeltaX=(randInt(200)-100)*Screen.pixelW;return this.targetY=(randInt(130)+30)*Screen.pixelH};Guppie.prototype.update=function(delta){var deltaX,deltaY,targetX;targetX=Game.ship.x+this.targetDeltaX;deltaX=targetX-this.x;deltaY=this.targetY-this.y;if(Math.abs(deltaX)>10){if(deltaX>0){this.direction=1;this.facingLeft=false}else{this.direction=-1;this.facingLeft=true}this.x+=this.direction*this.hSpeed*delta}else{this.setRandomTargetDelta()}if(Math.abs(deltaY)>10){if(deltaY>0){this.direction=1}else{this.direction=-1}this.y+=this.direction*this.vSpeed*delta}if(!this.offScreen&&Math.random()>0.99){return this.fire()}};Guppie.prototype.fire=function(){var direction,shotOffset,shotSpeed;shotOffset=Screen.pixelW*4;shotSpeed=20*Screen.pixelD;direction=Math.random()*Math.PI*2;return Game.world.getNextEnemyShot().fire(this.x+shotOffset,this.y+2*Screen.pixelH,shotSpeed,direction)};return Guppie})(Enemy);window.UFO=UFO;window.Guppie=Guppie;Building=(function(superClass){extend(Building,superClass);function Building(x3,y3){this.x=x3;this.y=y3;this.sprite=sprites.building;Building.__super__.constructor.apply(this,arguments);this.offsetY= -this.h;this.canBeDestroyed=false;this.hitbox=buildHitbox(this.offsetX,this.offsetY,1,3,13,32)}return Building})(Enemy);Mine=(function(superClass){extend(Mine,superClass);function Mine(x3,y3){this.x=x3;this.y=y3;this.sprite=sprites.mine;Mine.__super__.constructor.apply(this,arguments);this.points=100;this.hitbox=buildHitbox(this.offsetX,this.offsetY,1,1,15,15)}Mine.prototype.onExplode=function(){var direction,j,len,ref,results,shotSpeed;shotSpeed=50*Screen.pixelD;ref=[0,Math.PI,-Math.PI/2,Math.PI/2];results=[];for(j=0,len=ref.length;j<len;j+=1){direction=ref[j];results.push(Game.world.getNextEnemyShot().fire(this.x,this.y,shotSpeed,direction))}return results};return Mine})(Enemy);Radar=(function(superClass){extend(Radar,superClass);function Radar(x3,y3){this.x=x3;this.y=y3;this.sprite=sprites.radar;Radar.__super__.constructor.apply(this,arguments);this.offsetY= -this.h;this.cooldown=Math.random()*5;this.firePattern=[3,0.5];this.patternIndex=0;this.points=100;this.hitbox=buildHitbox(this.offsetX,this.offsetY,1,2,15,16)}Radar.prototype.update=function(delta){this.cooldown-=delta;if(this.cooldown<0){if(!this.offScreen){this.fire()}this.patternIndex+=1;if(this.patternIndex===this.firePattern.length){this.patternIndex=0}return this.cooldown=this.firePattern[this.patternIndex]}};Radar.prototype.fire=function(){var direction,j,len,ref,results,shotSpeed;shotSpeed=50*Screen.pixelD;ref=[Math.PI,-Math.PI/2,0];results=[];for(j=0,len=ref.length;j<len;j+=1){direction=ref[j];results.push(Game.world.getNextEnemyShot().fire(this.x-3*Screen.pixelW,this.y-13*Screen.pixelH,shotSpeed,direction))}return results};return Radar})(Enemy);window.Building=Building;window.Mine=Mine;window.Radar=Radar;World=(function(){function World(level,ship){this.level=level;this.ship=ship;this.ctx=Screen.ctx;this.canvas=Screen.canvas;this.width=this.blockToPixelW(25*8);this.halfWidth=this.width/2;this.spawnWidth=this.width-this.blockToPixelW(3);this.cameraX=this.canvas.width/2;this.offScreenDist=this.cameraX+this.blockToPixelW(2);this.sky=this.blockToPixelH(2);this.ground=this.blockToPixelH(22);this.height=this.ground-this.sky;this.items=[];this.levelEnded=false;this.playerShots=new ItemPool(PlayerShot,10);this.enemyShots=new ItemPool(EnemyShot,200);this.particles=new ItemPool(Particle,2000);this.generate(this.level)}World.prototype.blockToPixelH=function(block){return block*8*Screen.pixelH};World.prototype.blockToPixelW=function(block){return block*8*Screen.pixelW};World.prototype.generate=function(levelNo){var i,item,j,k,l,len,len1,len2,m,n,o,q,ref,ref1,ref2,ref3,ref4,ref5,ref6;this.levelEnded=false;this.items=[];ref=this.playerShots.pool;for(j=0,len=ref.length;j<len;j+=1){item=ref[j];item.dead=true}ref1=this.enemyShots.pool;for(k=0,len1=ref1.length;k<len1;k+=1){item=ref1[k];item.dead=true}ref2=this.particles.pool;for(l=0,len2=ref2.length;l<len2;l+=1){item=ref2[l];item.dead=true}for(i=m=0,ref3=randInt(3)+4;0<=ref3?m<=ref3:m>=ref3;i=0<=ref3? ++m: --m){this.items.push(new Building(randInt(this.spawnWidth),this.ground))}for(i=n=0,ref4=4+levelNo;0<=ref4?n<=ref4:n>=ref4;i=0<=ref4? ++n: --n){this.items.push(new Radar(randInt(this.spawnWidth),this.ground))}for(i=o=0,ref5=5+2*levelNo;0<=ref5?o<=ref5:o>=ref5;i=0<=ref5? ++o: --o){this.items.push(new UFO(randInt(this.spawnWidth),randInt(this.blockToPixelH(11))+this.blockToPixelH(4.5)))}if(levelNo>2){for(i=q=0,ref6=2*levelNo;0<=ref6?q<=ref6:q>=ref6;i=0<=ref6? ++q: --q){this.items.push(new Mine(randInt(this.spawnWidth),randInt(this.blockToPixelH(11))+this.blockToPixelH(4.5)))}}this.guppies=levelNo>1;return this.nextGuppieSpawn=30};World.prototype.getNextPlayerShot=function(){return this.playerShots.getNextItem()};World.prototype.getNextEnemyShot=function(){return this.enemyShots.getNextItem()};World.prototype.addParticle=function(x,y,directionRad,speed,colour){return this.particles.getNextItem().fire(x,y,directionRad,speed,colour)};World.prototype.spawnGuppie=function(){this.nextGuppieSpawn=30;return this.items.push(new Guppie(this.ship.x+this.spawnWidth/2))};World.prototype.update=function(delta){var item,j,k,l,len,len1,len2,len3,lhs,m,ref,ref1,ref2,ref3,rhs;if(this.guppies){this.nextGuppieSpawn-=delta;if(this.nextGuppieSpawn<0){this.spawnGuppie()}}if(!(this.ship.dead||this.ship.autopilot||this.ship.warping)){if(keysDown.right){this.ship.moveH(delta,1)}else if(keysDown.left){this.ship.moveH(delta,-1)}if(keysDown.up){this.ship.moveV(delta,-1)}else if(keysDown.down){this.ship.moveV(delta,1)}this.ship.update(delta);if(keysDown.fire){this.ship.fireShot()}}if(this.ship.warping){this.ship.moveH(delta,1);this.ship.moveV(delta,1)}rhs=this.ship.x+this.halfWidth;lhs=this.ship.x-this.halfWidth;ref=this.playerShots.pool;for(j=0,len=ref.length;j<len;j+=1){item=ref[j];this.updateItem(item,delta,rhs,lhs)}ref1=this.items;for(k=0,len1=ref1.length;k<len1;k+=1){item=ref1[k];this.updateItem(item,delta,rhs,lhs)}ref2=this.enemyShots.pool;for(l=0,len2=ref2.length;l<len2;l+=1){item=ref2[l];this.updateItem(item,delta,rhs,lhs)}ref3=this.particles.pool;for(m=0,len3=ref3.length;m<len3;m+=1){item=ref3[m];this.updateItem(item,delta,rhs,lhs)}if(!(this.ship.dead||this.ship.autopilot||this.ship.warping)){this.seeIfEnemyHit();if(!this.ship.invulnerable){return this.seeIfPlayerHit()}}};World.prototype.updateItem=function(item,delta,rhs,lhs){if(item.dead){return}item.update(delta);if(item.x>rhs){item.x-=this.width}else if(item.x<lhs){item.x+=this.width}return item.offScreen=(Math.abs(item.x-this.ship.x)>this.offScreenDist)||item.y<9*Screen.pixelH||item.y>this.ground};World.prototype.draw=function(){var item,j,k,l,len,len1,len2,len3,m,offsetX,ref,ref1,ref2,ref3;this.ctx.fillStyle=Colours.GREEN;offsetX=this.ship.x-this.cameraX;this.ctx.fillRect(0,this.ground,this.canvas.width,this.blockToPixelH(1));ref=this.enemyShots.pool;for(j=0,len=ref.length;j<len;j+=1){item=ref[j];this.drawItem(item,offsetX)}ref1=this.items;for(k=0,len1=ref1.length;k<len1;k+=1){item=ref1[k];this.drawItem(item,offsetX)}ref2=this.playerShots.pool;for(l=0,len2=ref2.length;l<len2;l+=1){item=ref2[l];this.drawItem(item,offsetX)}ref3=this.particles.pool;for(m=0,len3=ref3.length;m<len3;m+=1){item=ref3[m];this.drawItem(item,offsetX)}if(this.ship.invulnerable){this.ctx.globalAlpha=0.5}this.drawItem(this.ship,offsetX);this.ctx.globalAlpha=1.0;return this.drawRadar()};World.prototype.drawItem=function(item,offsetX){if(item.dead||item.offScreen){return}return item.draw(offsetX)};World.prototype.drawRadar=function(){var halfScreen,item,j,len,offsetX,offsetY,ratioX,ratioY,ref,results,x,y;offsetX=this.ship.x;offsetY=this.sky;ratioX=this.canvas.width/this.width;ratioY=this.blockToPixelH(1)/this.height;halfScreen=this.canvas.width/2;this.ctx.fillStyle=Colours.BLUE;this.ctx.fillRect(halfScreen-12*Screen.pixelW,Screen.pixelH,25*Screen.pixelW,8*Screen.pixelH);this.ctx.fillStyle=Colours.WHITE;this.ctx.fillRect(0,9*Screen.pixelH,this.canvas.width,Screen.pixelH);ref=this.items;results=[];for(j=0,len=ref.length;j<len;j+=1){item=ref[j];if(!item.dead){x=(item.x-offsetX)*ratioX+halfScreen;y=(item.y-offsetY)*ratioY;this.ctx.fillRect(x,y,Screen.pixelW,Screen.pixelH);if(item instanceof Building){results.push(this.ctx.fillRect(x,y-Screen.pixelH,Screen.pixelW,Screen.pixelH))}else{results.push(void 0)}}else{results.push(void 0)}}return results};World.prototype.seeIfPlayerHit=function(){var item,j,k,len,len1,ref,ref1,results,shot;ref=this.enemyShots.pool;for(j=0,len=ref.length;j<len;j+=1){shot=ref[j];if(!shot.dead&&this.pointInHitbox(this.ship,shot.x,shot.y)){shot.dead=true;this.playerDies(shot.x,shot.y)}}ref1=this.items;results=[];for(k=0,len1=ref1.length;k<len1;k+=1){item=ref1[k];if(!item.dead&&this.hitboxesIntersect(this.ship,item)){results.push(this.playerDies(this.ship.x,this.ship.y))}else{results.push(void 0)}}return results};World.prototype.seeIfEnemyHit=function(){var item,j,len,ref,results,shot;ref=this.playerShots.pool;results=[];for(j=0,len=ref.length;j<len;j+=1){shot=ref[j];if(!shot.dead){results.push((function(){var k,len1,ref1,results1;ref1=this.items;results1=[];for(k=0,len1=ref1.length;k<len1;k+=1){item=ref1[k];if(item.canBeDestroyed&&!item.dead){if(this.hitboxesIntersect(shot,item)){shot.dead=true;results1.push(this.enemyDies(item,shot.x,shot.y))}else{results1.push(void 0)}}else{results1.push(void 0)}}return results1}).call(this))}else{results.push(void 0)}}return results};World.prototype.hitboxesIntersect=function(item1,item2){return item1.x+item1.hitbox.right>item2.x+item2.hitbox.left&&item2.x+item2.hitbox.right>item1.x+item1.hitbox.left&&item1.y+item1.hitbox.bottom>item2.y+item2.hitbox.top&&item2.y+item2.hitbox.bottom>item1.y+item1.hitbox.top};World.prototype.pointInHitbox=function(item,pointX,pointY){if(!item.hitbox){return false}return pointX>item.x+item.hitbox.left&&pointX<item.x+item.hitbox.right&&pointY>item.y+item.hitbox.top&&pointY<item.y+item.hitbox.bottom};World.prototype.playerDies=function(hitPointX,hitPointY){var hitPoint;hitPoint={x:hitPointX-this.ship.x,y:hitPointY-this.ship.y};this.explodeSprite(this.ship,hitPoint,1);return Game.respawnPlayer()};World.prototype.enemyDies=function(enemy,hitPointX,hitPointY){var enemiesRemaining,hitPoint,item,j,len,ref;hitPoint={x:hitPointX-enemy.x,y:hitPointY-enemy.y};this.explodeSprite(enemy,hitPoint,1);enemy.onExplode();enemy.dead=true;Game.score+=enemy.points;enemiesRemaining=0;ref=this.items;for(j=0,len=ref.length;j<len;j+=1){item=ref[j];if(!item.dead&&item.canBeDestroyed){enemiesRemaining+=1}}if(enemiesRemaining===0){return Game.warpToNextWorld()}};World.prototype.explodeSprite=function(gameItem,point,direction){var a,b,g,height,imageData,j,offset,origin,pixel,r,ref,ref1,results,sprite,v1,width,x,y;sprite=gameItem.sprite;imageData=sprite.getImageData(gameItem.facingLeft);width=sprite.imageW;height=sprite.imageH;origin={x:0,y:0};results=[];for(y=j=0,ref=height,ref1=Screen.pixelH;ref1>0?j<ref:j>ref;y=j+=ref1){results.push((function(){var k,ref2,ref3,results1;results1=[];for(x=k=0,ref2=width,ref3=Screen.pixelW;ref3>0?k<ref2:k>ref2;x=k+=ref3){offset=y*(width*4)+x*4;r=imageData[offset];g=imageData[offset+1];b=imageData[offset+2];a=imageData[offset+3];if(a>0){pixel={x:x+gameItem.offsetX,y:y+gameItem.offsetY};v1=Vectors.angleDistBetweenPoints(point,pixel);pixel.x+=gameItem.x;pixel.y+=gameItem.y;results1.push(this.addParticle(pixel.x,pixel.y,v1.angle,v1.distance/2+300,{r:r,g:g,b:b}))}else{results1.push(void 0)}}return results1}).call(this))}return results};return World})();window.World=World;Particle=(function(){function Particle(){this.w=Screen.pixelW*1.5;this.h=Screen.pixelH*1.5;this.offsetX=this.w/-2;this.offsetY=this.h/-2;this.dead=true;this.maxLife=Math.random()+2;this.colour={};this.drag=0.985}Particle.prototype.fire=function(x3,y3,directionRad,speed,rgbValues){this.x=x3;this.y=y3;directionRad+=Math.random()/10-0.05;speed*=0.9+Math.random()*0.2;this.dead=false;this.offScreen=false;this.hSpeed=Math.cos(directionRad)*speed;this.vSpeed=Math.sin(directionRad)*speed;this.life=this.maxLife;return this.initColour(rgbValues)};Particle.prototype.draw=function(cameraOffsetX){Screen.ctx.fillStyle=this.colour.hexString+this.colour.alphaHex;return Screen.ctx.fillRect(this.x+this.offsetX-cameraOffsetX,this.y+this.offsetY,this.w,this.h)};Particle.prototype.update=function(delta){var alpha,ratio;this.hSpeed*=this.drag;this.vSpeed*=this.drag;this.x+=this.hSpeed*delta;this.y+=this.vSpeed*delta;this.life-=delta;if(this.life<=0){return this.dead=true}else{ratio=this.life/this.maxLife;if(ratio<0.5){alpha=Math.round(ratio*2*255).toString(16);if(alpha.length===1){alpha='0'+alpha}return this.colour.alphaHex=alpha}}};Particle.prototype.initColour=function(rgbValues){var b,g,r;r=rgbValues.r.toString(16);if(r.length===1){r='0'+r}g=rgbValues.g.toString(16);if(g.length===1){g='0'+g}b=rgbValues.b.toString(16);if(b.length===1){b='0'+b}this.colour.rgb=rgbValues;this.colour.hexString='#'+r+g+b;return this.colour.alphaHex='ff'};return Particle})();window.Particle=Particle;Vectors={originPoint:function(){return{x:0,y:0}},degToRad:function(deg){return 0.017453292519943295*deg},radToDeg:function(rad){return 57.29577951308232*rad},rotatePoint:function(point,angle){var angleR,length,x,x1,y,y1;x=point[0];y=point[1];length=Math.sqrt(x*x+y*y);angleR=Math.acos(x/length);if(y<0){angleR=0-angleR}angleR+=angle;x1=Math.cos(angleR)*length;y1=Math.sin(angleR)*length;return[x1,y1]},rotatePath:function(path,angle){return path.map((function(_this){return function(p){return _this.rotatePoint(p,angle)}})(this))},addVectorToPoint:function(point,angRad,length){var newPoint;newPoint={x:0,y:0};newPoint.x=point.x+(Math.cos(angRad)*length);newPoint.y=point.y+(Math.sin(angRad)*length);return newPoint},addVectors:function(angle1,length1,angle2,length2){var angle,distance,x1,x2,xR,y1,y2,yR;x1=Math.cos(angle1)*length1;y1=Math.sin(angle1)*length1;x2=Math.cos(angle2)*length2;y2=Math.sin(angle2)*length2;xR=x1+x2;yR=y1+y2;distance=Math.sqrt(xR*xR+yR*yR);if(distance===0){return[0,0]}angle=Math.acos(xR/distance);if(yR<0){angle=0-angle}return{angle:angle,distance:distance}},angleDistBetweenPoints:function(fromPoint,toPoint){var angle,distance,x,y;if(fromPoint===toPoint){return 0}x=toPoint.x-fromPoint.x;y=toPoint.y-fromPoint.y;distance=Math.sqrt(x*x+y*y);angle=Math.acos(x/distance);if(y<0){angle=0-angle}return{angle:angle,distance:distance}},distBetweenPoints:function(fromPoint,toPoint){var x,y;if(fromPoint===toPoint){return 0}x=toPoint.x-fromPoint.x;y=toPoint.y-fromPoint.y;return Math.sqrt(x*x+y*y)},shapesWithinReach:function(shapeA,shapeB){return Vectors.distBetweenPoints(shapeA.position,shapeB.position)<shapeA.reach+shapeB.reach},shapeBounds:function(paths){var j,k,len,len1,maxX,maxY,minX,minY,path,point;if(paths.length===0||paths[0].length===0||paths[0][0].length===0){return{minX:0,minY:0,maxX:0,maxY:0}}minX=maxX=paths[0][0][1];minY=maxY=paths[0][0][1];for(j=0,len=paths.length;j<len;j+=1){path=paths[j];for(k=0,len1=path.length;k<len1;k+=1){point=path[k];if(point[0]<minX){minX=point[0]}if(point[0]>maxX){maxX=point[0]}if(point[1]<minY){minY=point[1]}if(point[1]>maxY){maxY=point[1]}}}return{minX:minX,maxX:maxX,minY:minY,maxY:maxY}},shapeCentre:function(paths){var bounds;bounds=this.shapeBounds(paths);return{x:(bounds.minX+bounds.maxX)/2,y:(bounds.minY+bounds.maxY)/2}},distFromOrigin:function(x,y){return Math.sqrt(x*x+y*y)},movePathOrigin:function(paths,originX,originY){var j,len,path,point,results;results=[];for(j=0,len=paths.length;j<len;j+=1){path=paths[j];results.push((function(){var k,len1,results1;results1=[];for(k=0,len1=path.length;k<len1;k+=1){point=path[k];if(point.length!==0){point[0]-=originX;results1.push(point[1]-=originY)}else{results1.push(void 0)}}return results1})())}return results},centrePath:function(paths){var centre;centre=Vectors.shapeCentre(paths);return Vectors.movePathOrigin(paths,centre.x,centre.y)},centrePathH:function(paths){var centre;centre=Vectors.shapeCentre(paths);return Vectors.movePathOrigin(paths,centre.x,0)},centrePathV:function(paths){var centre;centre=Vectors.shapeCentre(paths);return Vectors.movePathOrigin(paths,0,centre.y)}};window.Vectors=Vectors;ItemPool=(function(){function ItemPool(itemClass,poolSize){var i,j,ref;this.pool=[];for(i=j=0,ref=poolSize;0<=ref?j<=ref:j>=ref;i=0<=ref? ++j: --j){this.pool.push(new itemClass())}this.itemIndex=0}ItemPool.prototype.getNextItem=function(){var item;item=this.pool[this.itemIndex];this.itemIndex+=1;if(this.itemIndex===this.pool.length){this.itemIndex=0}return item};return ItemPool})();window.ItemPool=ItemPool}).call(this);
//# sourceMappingURL=combined.js.map