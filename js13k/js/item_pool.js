// Generated by CoffeeScript 1.12.5
(function() {
  var ItemPool;

  ItemPool = (function() {
    function ItemPool(itemClass, poolSize) {
      var i, j, ref;
      this.pool = [];
      for (i = j = 0, ref = poolSize; 0 <= ref ? j <= ref : j >= ref; i = 0 <= ref ? ++j : --j) {
        this.pool.push(new itemClass());
      }
      this.itemIndex = 0;
    }

    ItemPool.prototype.getNextItem = function() {
      var item;
      item = this.pool[this.itemIndex];
      this.itemIndex += 1;
      if (this.itemIndex === this.pool.length) {
        this.itemIndex = 0;
      }
      return item;
    };

    return ItemPool;

  })();

  window.ItemPool = ItemPool;

}).call(this);

//# sourceMappingURL=item_pool.js.map
