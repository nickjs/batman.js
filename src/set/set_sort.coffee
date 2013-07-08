#= require ./set_proxy
#= require ./set_observer

window.longestNondecreasingSubsequence = (values, compare) ->
  subsequenceLength = 0
  M = [] # the i'th element of M is the index of the last element of the non-decreasing subsequence of length i+1
  predecessors = []

  for val, index in values
    start = 0
    end = subsequenceLength

    while end >= start
      lastIndex = ((end - start) >> 1) + start

      if compare(values[M[lastIndex]], val) is 1
        end = lastIndex - 1
      else
        start = lastIndex + 1

    newIndex = end # at the end of the search, 'end' is the element before the position we want to insert into
    predecessors[index] = M[newIndex] # undefined if newIndex is -1

    if newIndex is subsequenceLength or compare(val, values[M[newIndex + 1]]) is -1
      M[newIndex + 1] = index
      subsequenceLength = Math.max(subsequenceLength, newIndex + 1)

  # build the subsequence from the predecessor array
  currIndex = M[subsequenceLength]
  subsequence = []
  while currIndex?
    subsequence.unshift values[currIndex]
    currIndex = predecessors[currIndex]
  subsequence

window.binarySearch = (array, item, compare, exactMatch = true) ->
  start = 0
  end = array.length - 1

  while end >= start
    index = ((end - start) >> 1) + start
    direction = compare(item, array[index])

    if direction > 0
      start = index + 1
    else if direction < 0
      end = index - 1
    else
      return if exactMatch or item != array[index] then index else -1

  return if exactMatch then -1 else start

class Batman.SetSort extends Batman.SetProxy
  constructor: (base, @key, order="asc") ->
    super(base)

    @descending = order.toLowerCase() is "desc"
    @isSorted = true

    if @isCollectionEventEmitter
      @_setObserver.observedItemKeys = [@key]
      @_setObserver.observerForItemAndKey = => => @_reIndex()

    @_reIndex()

  handleItemsAdded: (items) ->
    if false and items.length > Math.log(@_storage.length) * 5
      @_reIndex()
    else
      oldStorage = @_storage.slice()
      addedItems = []
      addedIndexes = []

      for item in items
        index = binarySearch(@_storage, item, @compareElements, false)
        if index >= 0
          @_storage.splice(index, 0, item)
          addedItems.push(item)
          addedIndexes.push(index)

      @set('length', @_storage.length)
      @fire('itemsWereAdded', addedItems, addedIndexes)
      @property('_storage').fire(@_storage, oldStorage, '_storage')

  handleItemsRemoved: (items) ->
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

  forEach: (iterator, ctx) ->
    iterator.call(ctx, e, i, this) for e, i in @toArray()
    return

  find: (block) ->
    @base.registerAsMutableSource()
    for item in @get('_storage')
      return item if block(item)

  _indexOfItem: (item) ->
    binarySearch(@_storage, item, @compareElements)

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
