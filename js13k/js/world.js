// Generated by CoffeeScript 1.12.5
(function() {
  var World;

  World = (function() {
    function World(level, ship) {
      this.level = level;
      this.ship = ship;
      this.ctx = Screen.ctx;
      this.canvas = Screen.canvas;
      this.width = this.blockToPixelW(25 * 8);
      this.halfWidth = this.width / 2;
      this.spawnWidth = this.width - this.blockToPixelW(3);
      this.cameraX = this.canvas.width / 2;
      this.offScreenDist = this.cameraX + this.blockToPixelW(2);
      this.sky = this.blockToPixelH(2);
      this.ground = this.blockToPixelH(22);
      this.height = this.ground - this.sky;
      this.items = [];
      this.levelEnded = false;
      this.playerShots = new ItemPool(PlayerShot, 10);
      this.enemyShots = new ItemPool(EnemyShot, 200);
      this.particles = new ItemPool(Particle, 2000);
      this.generate(this.level);
    }

    World.prototype.blockToPixelH = function(block) {
      return block * 8 * Screen.pixelH;
    };

    World.prototype.blockToPixelW = function(block) {
      return block * 8 * Screen.pixelW;
    };

    World.prototype.generate = function(levelNo) {
      var i, item, j, k, l, len, len1, len2, m, n, o, p, ref, ref1, ref2, ref3, ref4, ref5, ref6;
      this.levelEnded = false;
      this.items = [];
      ref = this.playerShots.pool;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        item.dead = true;
      }
      ref1 = this.enemyShots.pool;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        item = ref1[k];
        item.dead = true;
      }
      ref2 = this.particles.pool;
      for (l = 0, len2 = ref2.length; l < len2; l++) {
        item = ref2[l];
        item.dead = true;
      }
      for (i = m = 0, ref3 = randInt(3) + 4; 0 <= ref3 ? m <= ref3 : m >= ref3; i = 0 <= ref3 ? ++m : --m) {
        this.items.push(new Building(randInt(this.spawnWidth), this.ground));
      }
      for (i = n = 0, ref4 = 4 + levelNo; 0 <= ref4 ? n <= ref4 : n >= ref4; i = 0 <= ref4 ? ++n : --n) {
        this.items.push(new Radar(randInt(this.spawnWidth), this.ground));
      }
      for (i = o = 0, ref5 = 5 + 2 * levelNo; 0 <= ref5 ? o <= ref5 : o >= ref5; i = 0 <= ref5 ? ++o : --o) {
        this.items.push(new UFO(randInt(this.spawnWidth), randInt(this.blockToPixelH(11)) + this.blockToPixelH(4.5)));
      }
      if (levelNo > 2) {
        for (i = p = 0, ref6 = 2 * levelNo; 0 <= ref6 ? p <= ref6 : p >= ref6; i = 0 <= ref6 ? ++p : --p) {
          this.items.push(new Mine(randInt(this.spawnWidth), randInt(this.blockToPixelH(11)) + this.blockToPixelH(4.5)));
        }
      }
      this.guppies = levelNo > 1;
      return this.nextGuppieSpawn = 30;
    };

    World.prototype.getNextPlayerShot = function() {
      return this.playerShots.getNextItem();
    };

    World.prototype.getNextEnemyShot = function() {
      return this.enemyShots.getNextItem();
    };

    World.prototype.addParticle = function(x, y, directionRad, speed, colour) {
      return this.particles.getNextItem().fire(x, y, directionRad, speed, colour);
    };

    World.prototype.spawnGuppie = function() {
      this.nextGuppieSpawn = 30;
      return this.items.push(new Guppie(this.ship.x + this.spawnWidth / 2));
    };

    World.prototype.update = function(delta) {
      var item, j, k, l, len, len1, len2, len3, lhs, m, ref, ref1, ref2, ref3, rhs;
      if (this.guppies) {
        this.nextGuppieSpawn -= delta;
        if (this.nextGuppieSpawn < 0) {
          this.spawnGuppie();
        }
      }
      if (!(this.ship.dead || this.ship.autopilot || this.ship.warping)) {
        if (keysDown.right) {
          this.ship.moveH(delta, 1);
        } else if (keysDown.left) {
          this.ship.moveH(delta, -1);
        }
        if (keysDown.up) {
          this.ship.moveV(delta, -1);
        } else if (keysDown.down) {
          this.ship.moveV(delta, 1);
        }
        this.ship.update(delta);
        if (keysDown.fire) {
          this.ship.fireShot();
        }
      }
      if (this.ship.warping) {
        this.ship.moveH(delta, 1);
        this.ship.moveV(delta, 1);
      }
      rhs = this.ship.x + this.halfWidth;
      lhs = this.ship.x - this.halfWidth;
      ref = this.playerShots.pool;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        this.updateItem(item, delta, rhs, lhs);
      }
      ref1 = this.items;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        item = ref1[k];
        this.updateItem(item, delta, rhs, lhs);
      }
      ref2 = this.enemyShots.pool;
      for (l = 0, len2 = ref2.length; l < len2; l++) {
        item = ref2[l];
        this.updateItem(item, delta, rhs, lhs);
      }
      ref3 = this.particles.pool;
      for (m = 0, len3 = ref3.length; m < len3; m++) {
        item = ref3[m];
        this.updateItem(item, delta, rhs, lhs);
      }
      if (!(this.ship.dead || this.ship.autopilot || this.ship.warping)) {
        this.seeIfEnemyHit();
        if (!this.ship.invulnerable) {
          return this.seeIfPlayerHit();
        }
      }
    };

    World.prototype.updateItem = function(item, delta, rhs, lhs) {
      if (item.dead) {
        return;
      }
      item.update(delta);
      if (item.x > rhs) {
        item.x -= this.width;
      } else if (item.x < lhs) {
        item.x += this.width;
      }
      return item.offScreen = (Math.abs(item.x - this.ship.x) > this.offScreenDist) || item.y < 9 * Screen.pixelH || item.y > this.ground;
    };

    World.prototype.draw = function() {
      var item, j, k, l, len, len1, len2, len3, m, offsetX, ref, ref1, ref2, ref3;
      this.ctx.fillStyle = Colours.GREEN;
      offsetX = this.ship.x - this.cameraX;
      this.ctx.fillRect(0, this.ground, this.canvas.width, this.blockToPixelH(1));
      ref = this.enemyShots.pool;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        this.drawItem(item, offsetX);
      }
      ref1 = this.items;
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        item = ref1[k];
        this.drawItem(item, offsetX);
      }
      ref2 = this.playerShots.pool;
      for (l = 0, len2 = ref2.length; l < len2; l++) {
        item = ref2[l];
        this.drawItem(item, offsetX);
      }
      ref3 = this.particles.pool;
      for (m = 0, len3 = ref3.length; m < len3; m++) {
        item = ref3[m];
        this.drawItem(item, offsetX);
      }
      if (this.ship.invulnerable) {
        this.ctx.globalAlpha = 0.5;
      }
      this.drawItem(this.ship, offsetX);
      this.ctx.globalAlpha = 1.0;
      return this.drawRadar();
    };

    World.prototype.drawItem = function(item, offsetX) {
      if (item.dead || item.offScreen) {
        return;
      }
      return item.draw(offsetX);
    };

    World.prototype.drawRadar = function() {
      var halfScreen, item, j, len, offsetX, offsetY, ratioX, ratioY, ref, results, x, y;
      offsetX = this.ship.x;
      offsetY = this.sky;
      ratioX = this.canvas.width / this.width;
      ratioY = this.blockToPixelH(1) / this.height;
      halfScreen = this.canvas.width / 2;
      this.ctx.fillStyle = Colours.BLUE;
      this.ctx.fillRect(halfScreen - 12 * Screen.pixelW, Screen.pixelH, 25 * Screen.pixelW, 8 * Screen.pixelH);
      this.ctx.fillStyle = Colours.WHITE;
      this.ctx.fillRect(0, 9 * Screen.pixelH, this.canvas.width, Screen.pixelH);
      ref = this.items;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (!item.dead) {
          x = (item.x - offsetX) * ratioX + halfScreen;
          y = (item.y - offsetY) * ratioY;
          this.ctx.fillRect(x, y, Screen.pixelW, Screen.pixelH);
          if (item instanceof Building) {
            results.push(this.ctx.fillRect(x, y - Screen.pixelH, Screen.pixelW, Screen.pixelH));
          } else {
            results.push(void 0);
          }
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    World.prototype.seeIfPlayerHit = function() {
      var item, j, k, len, len1, ref, ref1, results, shot;
      ref = this.enemyShots.pool;
      for (j = 0, len = ref.length; j < len; j++) {
        shot = ref[j];
        if (!shot.dead && this.pointInHitbox(this.ship, shot.x, shot.y)) {
          shot.dead = true;
          this.playerDies(shot.x, shot.y);
        }
      }
      ref1 = this.items;
      results = [];
      for (k = 0, len1 = ref1.length; k < len1; k++) {
        item = ref1[k];
        if (!item.dead && this.hitboxesIntersect(this.ship, item)) {
          results.push(this.playerDies(this.ship.x, this.ship.y));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    World.prototype.seeIfEnemyHit = function() {
      var item, j, len, ref, results, shot;
      ref = this.playerShots.pool;
      results = [];
      for (j = 0, len = ref.length; j < len; j++) {
        shot = ref[j];
        if (!shot.dead) {
          results.push((function() {
            var k, len1, ref1, results1;
            ref1 = this.items;
            results1 = [];
            for (k = 0, len1 = ref1.length; k < len1; k++) {
              item = ref1[k];
              if (item.canBeDestroyed && !item.dead) {
                if (this.hitboxesIntersect(shot, item)) {
                  shot.dead = true;
                  results1.push(this.enemyDies(item, shot.x, shot.y));
                } else {
                  results1.push(void 0);
                }
              } else {
                results1.push(void 0);
              }
            }
            return results1;
          }).call(this));
        } else {
          results.push(void 0);
        }
      }
      return results;
    };

    World.prototype.hitboxesIntersect = function(item1, item2) {
      return item1.x + item1.hitbox.right > item2.x + item2.hitbox.left && item2.x + item2.hitbox.right > item1.x + item1.hitbox.left && item1.y + item1.hitbox.bottom > item2.y + item2.hitbox.top && item2.y + item2.hitbox.bottom > item1.y + item1.hitbox.top;
    };

    World.prototype.pointInHitbox = function(item, pointX, pointY) {
      if (!item.hitbox) {
        return false;
      }
      return pointX > item.x + item.hitbox.left && pointX < item.x + item.hitbox.right && pointY > item.y + item.hitbox.top && pointY < item.y + item.hitbox.bottom;
    };

    World.prototype.playerDies = function(hitPointX, hitPointY) {
      var hitPoint;
      hitPoint = {
        x: hitPointX - this.ship.x,
        y: hitPointY - this.ship.y
      };
      this.explodeSprite(this.ship, hitPoint, 1);
      return Game.respawnPlayer();
    };

    World.prototype.enemyDies = function(enemy, hitPointX, hitPointY) {
      var enemiesRemaining, hitPoint, item, j, len, ref;
      hitPoint = {
        x: hitPointX - enemy.x,
        y: hitPointY - enemy.y
      };
      this.explodeSprite(enemy, hitPoint, 1);
      enemy.onExplode();
      enemy.dead = true;
      Game.score += enemy.points;
      enemiesRemaining = 0;
      ref = this.items;
      for (j = 0, len = ref.length; j < len; j++) {
        item = ref[j];
        if (!item.dead && item.canBeDestroyed) {
          enemiesRemaining += 1;
        }
      }
      if (enemiesRemaining === 0) {
        return Game.warpToNextWorld();
      }
    };

    World.prototype.explodeSprite = function(gameItem, point, direction) {
      var a, b, g, height, imageData, j, offset, origin, pixel, r, ref, ref1, results, sprite, v1, width, x, y;
      sprite = gameItem.sprite;
      imageData = sprite.getImageData(gameItem.facingLeft);
      width = sprite.imageW;
      height = sprite.imageH;
      origin = {
        x: 0,
        y: 0
      };
      results = [];
      for (y = j = 0, ref = height, ref1 = Screen.pixelH; ref1 > 0 ? j < ref : j > ref; y = j += ref1) {
        results.push((function() {
          var k, ref2, ref3, results1;
          results1 = [];
          for (x = k = 0, ref2 = width, ref3 = Screen.pixelW; ref3 > 0 ? k < ref2 : k > ref2; x = k += ref3) {
            offset = y * (width * 4) + x * 4;
            r = imageData[offset];
            g = imageData[offset + 1];
            b = imageData[offset + 2];
            a = imageData[offset + 3];
            if (a > 0) {
              pixel = {
                x: x + gameItem.offsetX,
                y: y + gameItem.offsetY
              };
              v1 = Vectors.angleDistBetweenPoints(point, pixel);
              pixel.x += gameItem.x;
              pixel.y += gameItem.y;
              results1.push(this.addParticle(pixel.x, pixel.y, v1.angle, v1.distance / 2 + 300, {
                r: r,
                g: g,
                b: b
              }));
            } else {
              results1.push(void 0);
            }
          }
          return results1;
        }).call(this));
      }
      return results;
    };

    return World;

  })();

  window.World = World;

}).call(this);

//# sourceMappingURL=world.js.map
