#= require ../enumerable
#= require ../hash/simple_hash

class Batman.SimpleSet
  constructor: (items=[]) ->
    if arguments.length > 1
      Batman.developer.error('Batman.SimpleSet constructor takes an array of items! Try `new Batman.Set([item1, item2])` instead.')
    @_storage = []
    @length = 0
    itemsToAdd = (item for item in items when item?)
    @add(itemsToAdd...) if itemsToAdd.length > 0

  Batman.extend @prototype, Batman.Enumerable

  at: (index) -> @_storage[index]

  add: (items...) ->
    # @ can be a SetSort, so have to specify SimpleSet
    Batman.SimpleSet::addArray.call(this, items)

  addArray: (items) ->
    addedItems = []
    for item in items when @_indexOfItem(item) == -1
      @_storage.push(item)
      addedItems.push(item)

    @length = @_storage.length
    addedItems

  insert: -> @insertWithIndexes(arguments...).addedItems

  insertWithIndexes: (items, indexes) ->
    addedIndexes = []
    addedItems = []
    for item, i in items when @_indexOfItem(item) == -1
      index = indexes[i]
      @_storage.splice(index, 0, item)
      addedItems.push(item)
      addedIndexes.push(index)

    @length = @_storage.length
    {addedItems, addedIndexes}

  remove: -> @removeWithIndexes(arguments...).removedItems

  removeWithIndexes: (items...) ->
    removedIndexes = []
    removedItems = []
    for item in items when (index = @_indexOfItem(item)) != -1
      @_storage.splice(index, 1)
      removedItems.push(item)
      removedIndexes.push(index)

    @length = @_storage.length
    {removedItems, removedIndexes}

  clear: ->
    items = @_storage
    @_storage = []
    @length = 0
    items

  replace: (other) ->
    @clear()
    @add(other.toArray()...)

  has: (item) -> @_indexOfItem(item) != -1

  find: (fn) ->
    for item in @_storage
      return item if fn(item)
    return

  forEach: (iterator, ctx) ->
    iterator.call(ctx, key, null, this) for key in @_storage
    return

  isEmpty: -> @length is 0

  toArray: -> @_storage.slice()

  merge: (others...) ->
    merged = new @constructor
    others.unshift(@)
    for set in others
      set.forEach (v) -> merged.add v
    merged

  mappedTo: (key) ->
    @_mappings ||= new Batman.SimpleHash
    @_mappings.getOrSet key, => new Batman.SetMapping(@, key)

  indexedBy: (key) ->
    @_indexes ||= new Batman.SimpleHash
    @_indexes.get(key) or @_indexes.set(key, new Batman.SetIndex(this, key))

  indexedByUnique: (key) ->
    @_uniqueIndexes ||= new Batman.SimpleHash
    @_uniqueIndexes.get(key) or @_uniqueIndexes.set(key, new Batman.UniqueSetIndex(this, key))

  sortedBy: (key, order="asc") ->
    order = if order.toLowerCase() is "desc" then "desc" else "asc"
    @_sorts ||= new Batman.SimpleHash
    sortsForKey = @_sorts.get(key) or @_sorts.set(key, new Batman.Object)
    sortsForKey.get(order) or sortsForKey.set(order, new Batman.SetSort(this, key, order))

  equality: Batman.SimpleHash::equality

  _indexOfItem: (givenItem) ->
    for item, index in @_storage
      return index if @equality(givenItem, item)
    return -1
