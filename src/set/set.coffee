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

  for k in ['indexedBy', 'indexedByUnique', 'sortedBy', 'equality', '_indexOfItem']
    @::[k] = Batman.SimpleSet::[k]

  for k in ['at', 'find', 'merge', 'forEach', 'toArray', 'isEmpty', 'has']
    do (k) =>
      @::[k] = ->
        @registerAsMutableSource()
        Batman.SimpleSet::[k].apply(@, arguments)

  toJSON: @::toArray

  add: @mutation ->
    addedItems = Batman.SimpleSet::add.apply(this, arguments)
    @fire('itemsWereAdded', addedItems) if addedItems.length
    addedItems

  insert: @mutation (items, indexes, addedIndexes = []) ->
    addedItems = Batman.SimpleSet::insert.apply(this, arguments)
    @fire('itemsWereAdded', addedItems, addedIndexes) if addedItems.length
    addedItems

  remove: @mutation ->
    removedIndexes = []
    removedItems = Batman.SimpleSet::remove.call(this, arguments..., removedIndexes)
    @fire('itemsWereRemoved', removedItems, removedIndexes) if removedItems.length
    removedItems

  addAndRemove: @mutation (itemsToAdd, itemsToRemove) ->
    addedItems = Batman.SimpleSet::add.apply(this, itemsToAdd || [])
    removedItems = Batman.SimpleSet::remove.apply(this, itemsToRemove || [])
    @fire('itemsWereAdded', addedItems) if addedItems.length
    @fire('itemsWereRemoved', removedItems) if removedItems.length

    added: addedItems
    removed: removedItems

  clear: @mutation ->
    removedItems = Batman.SimpleSet::clear.call(this)
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    removedItems

  replace: @mutation (other) ->
    removedItems = Batman.SimpleSet::clear.call(this)
    addedItems = Batman.SimpleSet::add.apply(this, other.toArray())
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    @fire('itemsWereAdded', addedItems) if addedItems.length
