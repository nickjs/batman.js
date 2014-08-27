BatmanObject = require '../object/object'
Enumerable = require '../enumerable'
SimpleSet = require './simple_set'
TerminalAccessible = require '../object/terminal_accessible'
{extend} = require '../object_helpers'

module.exports = class Set extends BatmanObject
  isCollectionEventEmitter: true

  constructor: (items=[]) ->
    SimpleSet.call(@, items)

  extend(@prototype, Enumerable)

  @_applySetAccessors = (klass) ->
    accessors =
      first:   -> @toArray()[0]
      last:    -> @toArray()[@length - 1]
      isEmpty: -> @isEmpty()
      toArray: -> @toArray()
      length:  -> @registerAsMutableSource(); @length
      indexedBy:          -> new TerminalAccessible (key) => @indexedBy(key)
      indexedByUnique:    -> new TerminalAccessible (key) => @indexedByUnique(key)
      sortedBy:           -> new TerminalAccessible (key) => @sortedBy(key)
      sortedByDescending: -> new TerminalAccessible (key) => @sortedBy(key, 'desc')
      mappedTo:           -> new TerminalAccessible (key) => @mappedTo(key)
      at:                 -> new TerminalAccessible (key) => @at(+key)
    klass.accessor(key, accessor) for key, accessor of accessors
    return

  @_applySetAccessors(@)

  for k in ['indexedBy', 'indexedByUnique', 'sortedBy', 'equality', '_indexOfItem', 'mappedTo']
    @::[k] = SimpleSet::[k]

  for k in ['at', 'find', 'merge', 'forEach', 'toArray', 'isEmpty', 'has']
    do (k) =>
      @::[k] = ->
        @registerAsMutableSource()
        SimpleSet::[k].apply(this, arguments)

  toJSON: -> @map (value) -> value.toJSON?() || value

  add: (items...) ->
    @addArray(items)

  addArray: @mutation ->
    addedItems = SimpleSet::addArray.apply(this, arguments)
    @fire('itemsWereAdded', addedItems) if addedItems.length
    addedItems

  insert: ->
    @insertWithIndexes(arguments...).addedItems

  insertWithIndexes: @mutation ->
    {addedItems, addedIndexes} = SimpleSet::insertWithIndexes.apply(this, arguments)
    @fire('itemsWereAdded', addedItems, addedIndexes) if addedItems.length
    {addedItems, addedIndexes}

  remove: (items...) ->
    @removeArrayWithIndexes(items).removedItems

  removeArray: (items) ->
    @removeArrayWithIndexes(items).removedItems

  removeWithIndexes: (items...) ->
    @removeArrayWithIndexes(items)

  removeArrayWithIndexes: @mutation (items) ->
    {removedItems, removedIndexes} = SimpleSet::removeArrayWithIndexes.call(this, items)
    @fire('itemsWereRemoved', removedItems, removedIndexes) if removedItems.length
    {removedItems, removedIndexes}

  clear: @mutation ->
    removedItems = SimpleSet::clear.call(this)
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    removedItems

  replace: @mutation (other) ->
    removedItems = SimpleSet::clear.call(this)
    array = other.toArray?() || other
    addedItems = SimpleSet::addArray.call(this, array)
    @fire('itemsWereRemoved', removedItems) if removedItems.length
    @fire('itemsWereAdded', addedItems) if addedItems.length
