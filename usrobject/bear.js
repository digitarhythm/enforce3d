var bear,
  __hasProp = Object.prototype.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor; child.__super__ = parent.prototype; return child; };

bear = (function(_super) {

  __extends(bear, _super);

  function bear(sprite) {
    this.sprite = sprite;
    bear.__super__.constructor.call(this, this.sprite);
  }

  bear.prototype.destructor = function() {
    return bear.__super__.destructor.call(this);
  };

  bear.prototype.behavior = function() {
    bear.__super__.behavior.call(this);
    switch (this._processnumber) {
      case 0:
        if (this.sprite.y > SCREEN_HEIGHT - this.sprite.height) {
          this.sprite.y = SCREEN_HEIGHT - this.sprite.height;
          this.sprite.ys *= -1;
        }
        if (this.sprite.x > SCREEN_WIDTH - this.sprite.width) {
          this.sprite.x = SCREEN_WIDTH - this.sprite.width;
          this.sprite.xs *= -1;
        }
        if (this.sprite.x < 0) {
          this.sprite.x = 0;
          return this.sprite.xs *= -1;
        }
    }
  };

  return bear;

})(_stationary);