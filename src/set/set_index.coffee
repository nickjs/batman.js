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

      @_setObserver.on 'itemsWereAdded', (items...) =>
        @itemsByKey(items).forEach @_addItems.bind(@)
        return

      @_setObserver.on 'itemsWereRemoved', (items...) =>
        @itemsByKey(items).forEach @_removeItems.bind(@)
        return

    @itemsByKey(@base).forEach @_addItems.bind(@)
    @startObserving()

  @accessor (key) -> @_resultSetForKey(key)

  itemsByKey: (items) ->
    byKey = new Batman.SimpleHash
    if items.forEach
      items.forEach (item) =>
        key = @_keyForItem(item)
        arr = byKey.get(key)
        unless arr
          arr = byKey.set(key, [])
        arr.push(item)
    else
      for item in items
        key = @_keyForItem(item)
        arr = byKey.get(key)
        unless arr
          arr = byKey.set(key, [])
        arr.push(item)
    byKey

  startObserving: -> @_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()

  observerForItemAndKey: (item, key) ->
    (newKey, oldKey) =>
      @_removeItems(oldKey, [item])
      @_addItems(newKey, [item])

  forEach: (iterator, ctx) ->
    @_storage.forEach (key, set) =>
      iterator.call(ctx, key, set, this) if set.get('length') > 0

  toArray: ->
    results = []
    @_storage.forEach (key, set) -> results.push(key) if set.get('length') > 0
    results

  _addItems: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.add(items...)
    resultSet

  _removeItems: (key, items) ->
    resultSet = @_resultSetForKey(key)
    resultSet.remove(items...)
    resultSet

  _resultSetForKey: (key) ->
    @_storage.getOrSet(key, -> new Batman.Set)

  _keyForItem: (item) ->
    Batman.Keypath.forBaseAndKey(item, @key).getValue()
