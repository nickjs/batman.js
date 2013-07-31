#= require ./set_proxy
#= require ./set_observer

class Batman.SetSort extends Batman.SetProxy
  constructor: (base, @key, order="asc") ->
    super(base)

    @descending = order.toLowerCase() is "desc"
    @isSorted = true

    if @isCollectionEventEmitter
      @_setObserver.observedItemKeys = [@key]
      @_setObserver.observerForItemAndKey = (item) => (newValue, oldValue) => @_handleItemsModified(item, newValue, oldValue)

    @_reIndex()

  _handleItemsModified: (item, newValue, oldValue) ->
    # at this point, item already has the new value set, so we need to use a different object for comparison
    proxyItem = {}
    proxyItem[@key] = oldValue

    wrappedCompare = (a, b) =>
      a = proxyItem if a is item
      b = proxyItem if b is item
      @compareElements(a, b)

    newStorage = @_storage.slice()

    {match, index: oldIndex} = @constructor._binarySearch(newStorage, item, wrappedCompare)
    return unless match
    newStorage.splice(oldIndex, 1)

    {match, index: newIndex} = @constructor._binarySearch(newStorage, item, @compareElements)

    return if oldIndex == newIndex

    newStorage.splice(newIndex, 0, item)
    @set('_storage', newStorage)
    @fire('itemWasMoved', item, newIndex, oldIndex)

  _handleItemsAdded: (items) ->
    # if items.length > Math.log(@_storage.length) * 5
    #   @_reIndex()
    # else
    newStorage = @_storage.slice()
    addedItems = []
    addedIndexes = []

    for item in items
      {match, index} = @constructor._binarySearch(newStorage, item, @compareElements)
      if not match # deduplicate insertion
        newStorage.splice(index, 0, item)
        addedItems.push(item)
        addedIndexes.push(index)

    @set('_storage', newStorage)
    @set('length', @_storage.length)
    @fire('itemsWereAdded', addedItems, addedIndexes)

  _handleItemsRemoved: (items) ->
    newStorage = @_storage.slice()
    removedItems = []
    removedIndexes = []

    for item in items
      {match, index} = @constructor._binarySearch(newStorage, item, @compareElements)
      if match
        newStorage.splice(index, 1)
        removedItems.push(item)
        removedIndexes.push(index)

    @set('_storage', newStorage)
    @set('length', @_storage.length)
    @fire('itemsWereRemoved', removedItems, removedIndexes)

  toArray: -> @get('_storage').slice()

  toArrayOfKeys: ->
    for item in @get('_storage')
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
    valueA = if @key and a? then Batman.get(a, @key) else a
    if typeof valueA is 'function'
      valueA = valueA.call(a)

    valueA = valueA.valueOf() if valueA?

    valueB = if @key and b? then Batman.get(b, @key) else b
    if typeof valueB is 'function'
      valueB = valueB.call(b)

    valueB = valueB.valueOf() if valueB?
    multiple = if @descending then -1 else 1
    @compare(valueA, valueB) * multiple

  _reIndex: ->
    newOrder = @base.toArray().sort(@compareElements)
    @_setObserver?.startObservingItems(newOrder)
    @set('_storage', newOrder)

  _indexOfItem: (target) ->
    {match, index} = @constructor._binarySearch(@_storage, target, @compareElements)
    if match then index else -1

  @_binarySearch: (arr, target, compare) ->
    start = 0
    end = arr.length - 1

    result = {}

    while end >= start
      index = ((end - start) >> 1) + start
      direction = compare(target, arr[index])

      if direction > 0
        start = index + 1
      else if direction < 0
        end = index - 1
      else
        # This bit performs a linear search within elements of the same key as the target.

        matched = false
        i = index
        while i >= 0 and compare(target, arr[i]) is 0
          if target is arr[i]
            index = i
            matched = true
            break
          i--

        unless matched
          i = index + 1
          while i < arr.length and compare(target, arr[i]) is 0
            if target is arr[i]
              index = i
              matched = true
              break
            i++

        return match: matched, index: index

    return match: false, index: start

