// Generated by CoffeeScript 1.12.5
(function() {
  var Particle, ParticleContainer;

  ParticleContainer = {
    init: function() {
      var i, j;
      this.particles = [];
      for (i = j = 0; j <= 200; i = ++j) {
        this.particles.push(new Particle());
      }
      return this.nextParticle = 0;
    },
    add: function(x, y, directionRad, speed, colour) {
      var particle;
      particle = this.particles[this.nextParticle];
      this.nextParticle += 1;
      if (this.nextParticle === this.particles.length) {
        this.nextParticle = 0;
      }
      return particle.fire(x, y, directionRad, speed, colour);
    }
  };

  Particle = (function() {
    function Particle() {
      this.w = Screen.pixelH;
      this.h = Screen.pixelH;
      this.offsetX = this.w / -2;
      this.offsetY = this.h / -2;
      this.dead = true;
    }

    Particle.prototype.fire = function(x1, y1, directionRad, speed, colour1) {
      this.x = x1;
      this.y = y1;
      this.colour = colour1;
      this.dead = false;
      this.offScreen = false;
      this.hSpeed = Math.cos(directionRad) * speed;
      return this.vSpeed = Math.sin(directionRad) * speed;
    };

    Particle.prototype.draw = function(cameraOffsetX) {
      this.sprite.draw(this.x + this.offsetX - cameraOffsetX, this.y + this.offsetY, false);
      this.ctx.fillStyle = this.colour;
      return this.ctx.fillRect(this.x + this.offsetX - cameraOffsetX, this.y + this.offsetY, this.w, this.h);
    };

    Particle.prototype.update = function(delta) {
      this.x += this.hSpeed * delta;
      return this.y += this.vSpeed * delta;
    };

    return Particle;

  })();

  window.Particle = Particle;

}).call(this);

//# sourceMappingURL=particles.js.map
