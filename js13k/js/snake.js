// Generated by CoffeeScript 1.12.5
(function() {
  var Snake,
    extend = function(child, parent) { for (var key in parent) { if (hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; },
    hasProp = {}.hasOwnProperty;

  Snake = (function(superClass) {
    extend(Snake, superClass);

    function Snake(x, direction) {
      this.x = x;
      this.direction = direction;
      this.sprite = sprites.snake;
      this.base = Screen.pixelH * 8 * 10;
      this.y = this.base;
      this.vSpeed = 200 * Screen.pixelH;
      this.hSpeed = 30 * Screen.pixelW;
      Snake.__super__.constructor.apply(this, arguments);
      this.points = 100;
      this.hitbox = buildHitbox(this.offsetX, this.offsetY, 1, 2, 14, 14);
    }

    Snake.prototype.update = function(delta) {
      this.x += this.direction * this.hSpeed * delta;
      this.y = this.base + Math.sin(this.x / 200) * 8 * 7 * Screen.pixelH;
      if (!this.offScreen && Math.random() > 0.991) {
        return this.fire();
      }
    };

    Snake.prototype.fire = function() {
      var shotSpeed;
      shotSpeed = 150 * Screen.pixelH;
      Game.world.getNextEnemyShot().fire(this.x, this.y, shotSpeed, 0);
      return Game.world.getNextEnemyShot().fire(this.x, this.y, shotSpeed, Math.PI);
    };

    return Snake;

  })(Enemy);

  window.Snake = Snake;

}).call(this);

//# sourceMappingURL=snake.js.map