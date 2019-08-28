// Generated by CoffeeScript 1.12.5
(function() {
  var EnemyShot, UFO;

  UFO = (function() {
    function UFO(x, base) {
      this.x = x;
      this.base = base;
      this.sprite = sprites.ufo;
      this.w = this.sprite.imageW;
      this.h = this.sprite.imageH;
      this.offsetX = this.w / -2;
      this.offsetY = this.h / -2;
      this.y = this.base;
      this.direction = Math.random() > 0.5 ? 1 : -1;
      this.facingLeft = this.direction < 0;
      this.vSpeed = 200 * Screen.pixelH;
      this.hSpeed = 30 * Screen.pixelW;
      this.canBeDestroyed = true;
      this.points = 50;
      this.hitbox = buildHitbox(this.offsetX, this.offsetY, 0, 0, 16, 9);
    }

    UFO.prototype.draw = function(cameraOffsetX) {
      return this.sprite.draw(this.x + this.offsetX - cameraOffsetX, this.y + this.offsetY, this.facingLeft);
    };

    UFO.prototype.update = function(delta) {
      this.x += this.direction * this.hSpeed * delta;
      this.y = this.base + Math.sin(this.x / 100) * 30;
      if (!this.offScreen && Math.random() > 0.99) {
        return this.fire();
      }
    };

    UFO.prototype.fire = function() {
      var direction, shotOffset, shotSpeed;
      shotOffset = Screen.pixelW * 4;
      shotSpeed = 20 * Screen.pixelD;
      direction = Math.random() * Math.PI * 2;
      return Game.world.getNextEnemyShot().fire(this.x + shotOffset, this.y + 2 * Screen.pixelH, shotSpeed, direction);
    };

    return UFO;

  })();

  EnemyShot = (function() {
    function EnemyShot() {
      this.sprite = sprites.enemyShot;
      this.w = this.sprite.imageW;
      this.h = this.sprite.imageH;
      this.offsetX = this.w / -2;
      this.offsetY = this.h / -2;
      this.dead = true;
    }

    EnemyShot.prototype.fire = function(x, y, speed, directionRad) {
      this.x = x;
      this.y = y;
      this.dead = false;
      this.offScreen = false;
      this.hSpeed = Math.cos(directionRad) * speed;
      return this.vSpeed = Math.sin(directionRad) * speed;
    };

    EnemyShot.prototype.draw = function(cameraOffsetX) {
      return this.sprite.draw(this.x + this.offsetX - cameraOffsetX, this.y + this.offsetY, false);
    };

    EnemyShot.prototype.update = function(delta) {
      this.x += this.hSpeed * delta;
      this.y += this.vSpeed * delta;
      if (this.offScreen) {
        return this.dead = true;
      }
    };

    return EnemyShot;

  })();

  window.UFO = UFO;

  window.EnemyShot = EnemyShot;

}).call(this);

//# sourceMappingURL=ufo.js.map