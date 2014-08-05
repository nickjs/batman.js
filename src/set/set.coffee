#= require ../object
#= require ./simple_set
#= require ../enumerable

class Batman.Set extends Batman.Object
  isCollectionEventEmitter: true

  constructor: (items=[]) ->
    if arguments.length > 1
      Batman.developer.warn("Batman.Set constructor takes an array of items! Try `new Batman.Set([item1, item2])` instead.")
    Batman.SimpleSet.call(@, items)

  Batman.extend @prototype, Batman.Enumerable

  @_applySetAccessors = (klass) ->
    accessors =
      first:   -> @toArray()[0]
      last:    -> @toArray()[@length - 1]
      isEmpty: -> @isEmpty()
      toArray: -> @toArray()
      length:  -> @registerAsMutableSource(); @length
      indexedBy:          -> new Batman.TerminalAccessible (key) => @indexedBy(key)
      indexedByUnique:    -> new Batman.TerminalAccessible (key) => @indexedByUnique(key)
      sortedBy:           -> new Batman.TerminalAccessible (key) => @sortedBy(key)
      sortedByDescending: -> new Batman.TerminalAccessible (key) => @sortedBy(key, 'desc')
      mappedTo:           -> new Batman.TerminalAccessible (key) => @mappedTo(key)
      at:                 -> new Batman.TerminalAccessible (key) => @at(+key)
    klass.accessor(key, accessor) for key, accessor of accessors
    return

  @_applySetAccessors(@)

  for k in ['indexedBy', 'indexedByUnique', 'sortedBy', 'equality', '_indexOfItem', 'mappedTo']
    @::[k] = Batman.SimpleSet::[k]

  for k in ['at', 'find', 'merge', 'forEach', 'toArray', 'isEmpty', 'has']
    do (k) =>
      @::[k] = ->
        @registerAsMutableSource()
        Batman.SimpleSet::[k].apply(this, arguments)

  toJSON: -> @map (value) -> value.toJSON?() || value

  add: (items...) ->
    @addArray(items)

  addArray: @mutation ->
    addedItems = Batman.SimpleSet::addArray.apply(this, arguments)
    @fire('itemsWereAdded', addedItems) if addedItems.length
    addedItems

  insert: ->
    @insertWithIndexes(arguments...).addedItems

  insertWithIndexes: @mutation ->
    {addedItems, addedIndexes} = Batman.SimpleSet::insertWithIndexes.apply(this, arguments)
    @fire('itemsWereAdded', addedItems, addedIndexes) if addedItems.length
    {addedItems, addedIndexes}

  remove: (items...) ->
    @removeArrayWithIndexes(items).removedItems

  removeArray: (items) ->
    @removeArrayWithIndexes(items).removedItems

  removeWithIndexes: (items...) ->
    @removeArrayWithIndexes(items)

  removeArrayWithIndexes: @mutation (items) ->
    {removedItems, removedIndexes} = Batman.SimpleSet::removeArrayWithIndexes.call(this, items)
    @fire('itemsWereRemoved', removedItems, removedIndexes) if removedItems.length
    {removedItems, removedIndexes}

  clear: @mutation ->
    removedItems = Batman.SimpleSet::clear.call(this)
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    removedItems

  replace: @mutation (other) ->
    removedItems = Batman.SimpleSet::clear.call(this)
    addedItems = Batman.SimpleSet::add.apply(this, other.toArray())
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    @fire('itemsWereAdded', addedItems) if addedItems.length
