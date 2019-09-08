// Generated by CoffeeScript 1.12.5
(function() {
  var Game, GameStates;

  GameStates = {
    PRE_LAUNCH: 'PRE_LAUNCH',
    TITLE_SCREEN: 'TITLE_SCREEN',
    PLAYING_IN_PLAY: 'PLAYING_IN_PLAY',
    PLAYING_WARPING: 'PLAYING_WARPING',
    PLAYING_WARPING_WIN: 'PLAYING_WARPING_WIN',
    START_OF_LEVEL: 'START_OF_LEVEL',
    PLAYING_SPAWNING: 'PLAYING_SPAWNING',
    GAME_OVER: 'GAME_OVER',
    PLAYER_WINS: 'PLAYER_WINS'
  };

  Game = {
    state: GameStates.PRE_LAUNCH,
    run: function() {
      this.ctx = Screen.ctx;
      this.canvas = Screen.canvas;
      this.cooldown = 0;
      Screen.setSize(25, 23);
      addChars(48, astroDigits);
      return this.showStory();
    },
    update: function(timestamp) {
      var delta;
      if (this.lastTimestamp) {
        delta = (timestamp - this.lastTimestamp) / 1000;
      } else {
        delta = 0;
      }
      this.lastTimestamp = timestamp;
      this.cooldown -= delta;
      if (this.state === GameStates.PRE_LAUNCH) {
        if (keysDown.fire && this.cooldown <= 0) {
          this.cooldown = 0.5;
          this.showTitleScreen();
        }
      } else if (this.state === GameStates.TITLE_SCREEN) {
        if (keysDown.fire && this.cooldown <= 0) {
          this.startGame();
        }
      } else {
        if (this.state === GameStates.GAME_OVER || this.state === GameStates.PLAYER_WINS) {
          if (keysDown.fire && this.cooldown <= 0) {
            this.state = GameStates.TITLE_SCREEN;
            this.cooldown = 1;
            this.showTitleScreen();
          }
        } else if (this.state === GameStates.PLAYING_SPAWNING) {
          if (this.cooldown < 0) {
            this.state = GameStates.PLAYING_IN_PLAY;
            this.ship.invulnerable = false;
          } else if (this.cooldown < 2) {
            this.ship.dead = false;
            this.ship.autopilot = false;
            this.ship.invulnerable = true;
          }
        } else if (this.state === GameStates.PLAYING_WARPING) {
          if (this.cooldown < 0) {
            this.state = GameStates.PLAYING_SPAWNING;
            this.ship.autopilot = false;
            this.ship.invulnerable = true;
            this.ship.warping = false;
            this.cooldown = 2;
          } else if (this.cooldown < 2 && this.world.levelEnded) {
            this.level += 1;
            this.world.generate(this.level);
          }
        } else if (this.state === GameStates.PLAYING_WARPING_WIN) {
          if (this.cooldown < 0) {
            this.state = GameStates.PLAYER_WINS;
            this.cooldown = 1;
            this.showEnding();
          }
        }
      }
      if (!(this.state === GameStates.TITLE_SCREEN || this.state === GameStates.PRE_LAUNCH || this.state === GameStates.PLAYER_WINS)) {
        this.world.update(delta);
        return this.draw();
      }
    },
    draw: function() {
      var i, j, levelText, ref;
      if (this.state === GameStates.PLAYING_WARPING) {
        Screen.screenColour = Colours.PURPLE;
        Screen.clear();
        Screen.textColour = Colours.WHITE;
        levelText = this.world.levelEnded ? this.level : this.level - 1;
        Screen.printAt(5, 8, "LEVEL " + levelText + " CLEARED");
        Screen.printAt(8, 10, 'WARPING ...');
        Screen.textColour = Colours.BLUE;
      } else if (this.state === GameStates.PLAYING_WARPING_WIN) {
        Screen.screenColour = Colours.GREEN;
        Screen.clear();
        Screen.textColour = Colours.WHITE;
        Screen.printAt(3, 8, "MISSION SUCCESSFUL!");
        Screen.printAt(7, 10, 'WARPING TO');
        Screen.printAt(3, 11, 'RENDEZVOUS POINT...');
        Screen.textColour = Colours.BLUE;
      } else {
        this.ctx.fillStyle = Colours.BLACK;
        this.ctx.fillRect(0, 0, this.canvas.width, this.canvas.height);
        Screen.textColour = Colours.WHITE;
      }
      Screen.printAt(1, 2, '' + this.score);
      Screen.printAt(12, 2, '' + this.level);
      if (this.livesLeft > 0) {
        for (i = j = 1, ref = this.livesLeft; 1 <= ref ? j <= ref : j >= ref; i = 1 <= ref ? ++j : --j) {
          Screen.printAt(24 - i, 2, '/');
        }
      }
      this.world.draw();
      if (this.state === GameStates.GAME_OVER) {
        Screen.textColour = Colours.WHITE;
        Screen.printAt(8, 8, 'GAME OVER');
        if (this.cooldown < 0) {
          return Screen.printAt(7, 10, 'Press  FIRE');
        }
      }
    },
    startGame: function() {
      this.state = GameStates.PLAYING_SPAWNING;
      Screen.clear();
      Screen.printAt(8, 4, "Playing ...");
      this.score = 0;
      this.kills = 0;
      this.shotsFired = 0;
      this.livesLeft = 4;
      this.level = 1;
      this.ship = new Ship();
      this.world = new World(1, this.ship);
      this.ship.y = this.world.blockToPixelH(13);
      return this.cooldown = 2;
    },
    warpToNextWorld: function() {
      if (this.level === 5) {
        this.state = GameStates.PLAYING_WARPING_WIN;
      } else {
        this.state = GameStates.PLAYING_WARPING;
      }
      this.cooldown = 5;
      this.ship.warping = true;
      return this.world.levelEnded = true;
    },
    endGame: function() {
      this.state = GameStates.GAME_OVER;
      return this.cooldown = 3;
    },
    respawnPlayer: function() {
      this.ship.dead = true;
      this.ship.autopilot = true;
      if (this.livesLeft === 0) {
        return this.endGame();
      } else {
        this.livesLeft -= 1;
        this.ship.y = 8 * 12 * Screen.pixelH;
        this.state = GameStates.PLAYING_SPAWNING;
        return this.cooldown = 3;
      }
    },
    hLine: function(row) {
      return Screen.printAt(0, row, ';;;;;;;;;;;;;;;;;;;;;;;;;');
    },
    showTitleScreen: function() {
      Typer.clear();
      this.state = GameStates.TITLE_SCREEN;
      Cursor.hide();
      Screen.setBorder(Colours.BLUE);
      Screen.screenColour = Colours.BLACK;
      Screen.textColour = Colours.WHITE;
      Screen.clear();
      Screen.printAt(8, 4, "JS BLITZ");
      Screen.printAt(0, 6, "COME WITH ME, BACK TO '83");
      this.hLine(7);
      Screen.printAt(15, 9, "50");
      Screen.printAt(15, 12, "50");
      Screen.printAt(15, 15, "100");
      Screen.printAt(15, 18, "150");
      Screen.printAt(1, 10, "MOVE");
      Screen.printAt(1, 12, "OR");
      Screen.printAt(1, 16, "FIRE");
      this.hLine(20);
      this.hLine(22);
      Screen.textColour = Colours.YELLOW;
      Screen.printAt(3, 21, 'PRESS SPACE TO START');
      Screen.textColour = Colours.CYAN;
      Screen.printAt(1, 11, "^ _ $ &");
      Screen.printAt(1, 13, "W A S D");
      Screen.printAt(1, 17, "SPACE");
      Screen.textColour = Colours.BLUE;
      Screen.drawSprite(96, 71, ufo);
      Screen.drawSprite(96, 88, radar);
      Screen.drawSprite(96, 112, mine);
      return Screen.drawSprite(96, 140, guppie);
    },
    showStory: function() {
      Screen.screenColour = Colours.BLACK;
      Screen.setBorder(Colours.BLACK);
      Screen.clear();
      Typer.display(['c:GREEN', 't:', 't: ** INCOMING  MESSAGE **', 't:', 't:Pilot,', 't:', "t:You've infiltrated       The Foundation's secret  research base and stolen their next gen fighter.", 't:', "t:Now you'll need to fight your way past their      defences on the five     outer moons, back to our ship waiting in deep     space.", 't:', 't:Fly well,', 't:The rebellion depends on you.', 'd: ', 'd:', 'c:BLUE', 'd:       Press SPACE']);
      return requestAnimationFrame(update);
    },
    showEnding: function() {
      Screen.screenColour = Colours.BLACK;
      Screen.setBorder(Colours.BLACK);
      Screen.clear();
      return Typer.display(['c:GREEN', 't:', 't: ** INCOMING  MESSAGE **', 't:', 't:Awesome skill, Pilot!', 't:', 't:The technology in this   ship will be invaluable  in our fight against     The Foundation and their evil schemes.', 't:', 't:Well done.', 't:', 't:', 'c:YELLOW', 't:   Score       ' + ('' + this.score).padStart(5, ' '), 't:   Kills       ' + ('' + this.kills).padStart(5, ' '), 't:   Shots fired ' + ('' + this.shotsFired).padStart(5, ' '), 't:   Accuracy    ' + ((this.kills / this.shotsFired * 100).toFixed(1) + '%').padStart(6, ' '), 't:', 'c:BLUE', 't:       Press SPACE', 'p:1']);
    }
  };

  window.update = function(timestamp) {
    Game.update(timestamp);
    if (window.paused) {
      console.log('Game is paused');
    } else {
      window.requestAnimationFrame(update);
    }
    return true;
  };

  window.keysDown = {
    left: false,
    right: false,
    up: false,
    down: false,
    fire: false
  };

  window.paused = false;

  window.keyToggled = function(keyCode, isPressed) {
    if (keyCode === 32) {
      window.keysDown.fire = isPressed;
    }
    if (keyCode === 38 || keyCode === 90 || keyCode === 87) {
      window.keysDown.up = isPressed;
    }
    if (keyCode === 39 || keyCode === 68) {
      window.keysDown.right = isPressed;
    }
    if (keyCode === 40 || keyCode === 83) {
      window.keysDown.down = isPressed;
    }
    if (keyCode === 37 || keyCode === 65 || keyCode === 81) {
      window.keysDown.left = isPressed;
    }
    if (keyCode === 66) {
      window.paused = isPressed;
      return console.log('Paused', window.paused);
    }
  };

  window.onkeydown = function(e) {
    return keyToggled(e.keyCode, true);
  };

  window.onkeyup = function(e) {
    return keyToggled(e.keyCode, false);
  };

  window.Game = Game;

  window.GameStates = GameStates;

}).call(this);

//# sourceMappingURL=game.js.map
