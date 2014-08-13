SetObserver = require './set_observer'
Set = require './set'
BatmanObject = require '../object/object'
Property = require '../observable/property'
Keypath = require '../observable/keypath'
Enumerable = require '../enumerable'
SimpleHash = require '../hash/simple_hash'
Hash = require '../hash/hash'
{extend} = require '../object_helpers'


module.exports = class SetIndex extends BatmanObject
  @accessor 'toArray', -> @toArray()
  extend(@prototype, Enumerable)
  propertyClass: Property

  constructor: (@base, @key) ->
    super()
    @_storage = new Hash

    if @base.isEventEmitter
      @_setObserver = new SetObserver(@base)
      @_setObserver.observedItemKeys = [@key]
      @_setObserver.observerForItemAndKey = @observerForItemAndKey.bind(@)
      @_setObserver.on 'itemsWereAdded', (items) => @_addItems(items)
      @_setObserver.on 'itemsWereRemoved', (items) => @_removeItems(items)

    @_addItems(@base._storage)
    @startObserving()

  @accessor (key) -> @_resultSetForKey(key)

  startObserving: -> @_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()

  observerForItemAndKey: (item, key) ->
    (newKey, oldKey) =>
      @_removeItemsFromKey(oldKey, [item])
      @_addItemsToKey(newKey, [item])

  forEach: (iterator, ctx) ->
    @_storage.forEach (key, set) =>
      iterator.call(ctx, key, set, this) if set.get('length') > 0

  toArray: ->
    results = []
    @_storage.forEach (key, set) -> results.push(key) if set.get('length') > 0
    results

  # Batch consecutive keys with the same items
  _addItems: (items) ->
    return unless items?.length
    lastKey = @_keyForItem(items[0])
    itemsForKey = []

    for item, index in items
      if SimpleHash::equality(lastKey, (key = @_keyForItem(item)))
        itemsForKey.push(item)
      else
        @_addItemsToKey(lastKey, itemsForKey)
        itemsForKey = [item]
        lastKey = key

    if itemsForKey.length
      @_addItemsToKey(lastKey, itemsForKey)

  _removeItems: (items) ->
    return unless items?.length
    lastKey = @_keyForItem(items[0])
    itemsForKey = []

    for item, index in items
      if SimpleHash::equality(lastKey, (key = @_keyForItem(item)))
        itemsForKey.push(item)
      else
        @_removeItemsFromKey(lastKey, itemsForKey)
        itemsForKey = [item]
        lastKey = key

    if itemsForKey.length
      @_removeItemsFromKey(lastKey, itemsForKey)

  _addItemsToKey: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.addArray(items)
    resultSet

  _removeItemsFromKey: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.removeArray(items)
    resultSet

  _resultSetForKey: (key) ->
    @_storage.getOrSet(key, -> new Set)

  _keyForItem: (item) ->
    Keypath.forBaseAndKey(item, @key).getValue()
