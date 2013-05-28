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
      @_setObserver.on 'itemsWereAdded', (items) =>
        @_addItem(item) for item in items
      @_setObserver.on 'itemsWereRemoved', (items) =>
        @_removeItem(item) for item in items
    @base.forEach @_addItem.bind(@)
    @startObserving()
  @accessor (key) -> @_resultSetForKey(key)
  startObserving: ->@_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()
  observerForItemAndKey: (item, key) ->
    (newValue, oldValue) =>
      @_removeItemFromKey(item, oldValue)
      @_addItemToKey(item, newValue)
  forEach: (iterator, ctx) ->
    @_storage.forEach (key, set) =>
      iterator.call(ctx, key, set, this) if set.get('length') > 0
  toArray: ->
    results = []
    @_storage.forEach (key, set) -> results.push(key) if set.get('length') > 0
    results
  _addItem: (item) -> @_addItemToKey(item, @_keyForItem(item))
  _addItemToKey: (item, key) ->
    @_resultSetForKey(key).add item
  _removeItem: (item) -> @_removeItemFromKey(item, @_keyForItem(item))
  _removeItemFromKey: (item, key) -> @_resultSetForKey(key).remove(item)
  _resultSetForKey: (key) ->
    @_storage.getOrSet(key, -> new Batman.Set)
  _keyForItem: (item) ->
    Batman.Keypath.forBaseAndKey(item, @key).getValue()
