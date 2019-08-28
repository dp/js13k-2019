class ItemPool
    constructor: (itemClass, poolSize) ->
        @pool = []
        for i in [0..poolSize]
            @pool.push new itemClass()
        @itemIndex = 0

    getNextItem: ->
        item = @pool[@itemIndex]
        @itemIndex += 1
        if @itemIndex == @pool.length
            @itemIndex = 0
        return item


window.ItemPool = ItemPool