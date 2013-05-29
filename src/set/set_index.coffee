#= require ./set
#= require ./set_observer
#= require ../object

class Batman.SetIndex extends Batman.Object
  @accessor 'toArray', -> @toArray()
  Batman.extend @prototype, Batman.Enumerable
  propertyClass: Batman.Property

  constructor: (@base, @key) ->
    super()
    @_storage = new Batman.Hash

    if @base.isEventEmitter
      @_setObserver = new Batman.SetObserver(@base)
      @_setObserver.observedItemKeys = [@key]
      @_setObserver.observerForItemAndKey = @observerForItemAndKey.bind(@)
      @_setObserver.on 'itemsWereAdded', (items...) => @_addItems(items)
      @_setObserver.on 'itemsWereRemoved', (items...) => @_removeItems(items)

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
      if Batman.SimpleHash::equality(lastKey, (key = @_keyForItem(item)))
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
      if Batman.SimpleHash::equality(lastKey, (key = @_keyForItem(item)))
        itemsForKey.push(item)
      else
        @_removeItemsFromKey(lastKey, itemsForKey)
        itemsForKey = [item]
        lastKey = key

    if itemsForKey.length
      @_removeItemsFromKey(lastKey, itemsForKey)

  _addItemsToKey: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.add(items...)
    resultSet

  _removeItemsFromKey: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.remove(items...)
    resultSet

  _resultSetForKey: (key) ->
    @_storage.getOrSet(key, -> new Batman.Set)

  _keyForItem: (item) ->
    Batman.Keypath.forBaseAndKey(item, @key).getValue()
