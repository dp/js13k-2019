// Generated by CoffeeScript 1.12.5
(function() {
  var Enemy, EnemyShot;

  Enemy = (function() {
    function Enemy() {
      this.w = this.sprite.imageW;
      this.h = this.sprite.imageH;
      this.offsetX = this.w / -2;
      this.offsetY = this.h / -2;
      this.direction = Math.random() > 0.5 ? 1 : -1;
      this.facingLeft = this.direction < 0;
      this.canBeDestroyed = true;
    }

    Enemy.prototype.draw = function(cameraOffsetX) {
      return this.sprite.draw(this.x + this.offsetX - cameraOffsetX, this.y + this.offsetY, this.facingLeft);
    };

    Enemy.prototype.update = function(delta) {
      return true;
    };

    Enemy.prototype.onExplode = function() {
      return true;
    };

    return Enemy;

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

  window.Enemy = Enemy;

  window.EnemyShot = EnemyShot;

}).call(this);

//# sourceMappingURL=enemy.js.map
