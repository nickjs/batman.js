#= require ./set_proxy
#= require ./set_observer

class Batman.SetSort extends Batman.SetProxy
  constructor: (base, @key, order="asc") ->
    super(base)

    @descending = order.toLowerCase() is "desc"
    @isSorted = true

    if @isCollectionEventEmitter
      @_setObserver.observedItemKeys = [@key]
      @_setObserver.observerForItemAndKey = => => @_reIndex()

    @_reIndex()

  _handleItemsAdded: (items) ->
    if false and items.length > Math.log(@_storage.length) * 5
      @_reIndex()
    else
      oldStorage = @_storage.slice()
      addedItems = []
      addedIndexes = []

      for item in items
        index = @_binarySearch(item, false)
        if index >= 0
          @_storage.splice(index, 0, item)
          addedItems.push(item)
          addedIndexes.push(index)

      @set('length', @_storage.length)
      @fire('itemsWereAdded', addedItems, addedIndexes)
      @property('_storage').fire(@_storage, oldStorage, '_storage')

  _handleItemsRemoved: (items) ->
    if false and items.length > Math.log(@_storage.length) * 5
      @_reIndex()
    else
      oldStorage = @_storage.slice()
      removedItems = []
      removedIndexes = []

      for item in items
        index = @_indexOfItem(item)
        if index >= 0
          @_storage.splice(index, 1)
          removedItems.push(item)
          removedIndexes.push(index)

      @set('length', @_storage.length)
      @fire('itemsWereRemoved', removedItems, removedIndexes)
      @property('_storage').fire(@_storage, oldStorage, '_storage')

  toArray: -> @get('_storage').slice()

  toArrayOfKeys: ->
    for item in @toArray()
      item.get(@key)

  forEach: (iterator, ctx) ->
    iterator.call(ctx, e, i, this) for e, i in @toArray()
    return

  find: (block) ->
    @base.registerAsMutableSource()
    for item in @get('_storage')
      return item if block(item)

  merge: (other) ->
    @base.registerAsMutableSource()
    new Batman.Set(@_storage...).merge(other).sortedBy(@key, @order)

  compare: (a, b) ->
    return 0 if a is b
    return 1 if a is undefined
    return -1 if b is undefined
    return 1 if a is null
    return -1 if b is null

    return 1 if a is false
    return -1 if b is false
    return 1 if a is true
    return -1 if b is true

    if a isnt a
      if b isnt b
        return 0 # both are NaN
      else
        return 1 # a is NaN
    return -1 if b isnt b # b is NaN

    return 1 if a > b
    return -1 if a < b
    return 0

  compareElements: (a, b) =>
    valueA = if @key then Batman.get(a, @key) else a
    if typeof valueA is 'function'
      valueA = valueA.call(a)

    valueA = valueA.valueOf() if valueA?

    valueB = if @key then Batman.get(b, @key) else b
    if typeof valueB is 'function'
      valueB = valueB.call(b)

    valueB = valueB.valueOf() if valueB?
    multiple = if @descending then -1 else 1
    @compare(valueA, valueB) * multiple

  _reIndex: ->
    newOrder = @base.toArray().sort @compareElements
    @_setObserver?.startObservingItems(newOrder)
    @set('_storage', newOrder)

  _binarySearch: (item, exactMatch = true) ->
    start = 0
    end = @_storage.length - 1

    while end >= start
      index = ((end - start) >> 1) + start
      direction = @compareElements(item, @_storage[index])

      if direction > 0
        start = index + 1
      else if direction < 0
        end = index - 1
      else
        return if exactMatch or item != @_storage[index] then index else -1

    return if exactMatch then -1 else start

  _indexOfItem: (item) -> @_binarySearch(item)

