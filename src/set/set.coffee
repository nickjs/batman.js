#= require ../object
#= require ./simple_set
#= require ../enumerable

class Batman.Set extends Batman.Object
  isCollectionEventEmitter: true

  constructor: -> Batman.SimpleSet.apply @, arguments

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

  add: @mutation ->
    addedItems = Batman.SimpleSet::add.apply(this, arguments)
    @fire('itemsWereAdded', addedItems) if addedItems.length
    addedItems

  insert: ->
    @insertWithIndexes(arguments...).addedItems

  insertWithIndexes: @mutation ->
    {addedItems, addedIndexes} = Batman.SimpleSet::insertWithIndexes.apply(this, arguments)
    @fire('itemsWereAdded', addedItems, addedIndexes) if addedItems.length
    {addedItems, addedIndexes}

  remove: ->
    @removeWithIndexes(arguments...).removedItems

  removeWithIndexes: @mutation ->
    {removedItems, removedIndexes} = Batman.SimpleSet::removeWithIndexes.apply(this, arguments)
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
