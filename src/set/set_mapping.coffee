#= require ./set
#= require ./set_observer

class Batman.SetMapping extends Batman.Set
  constructor: (@base, @key) ->
    initialValues = @base.mapToProperty(@key)
    @_counter = new @constructor.PresenceCounter(initialValues)
    super(initialValues...)
    @_setObserver = new Batman.SetObserver(@base)
    @_setObserver.observedItemKeys = [@key]
    @_setObserver.observerForItemAndKey = (item) => (newValue, oldValue) => @_handleItemModified(item, newValue, oldValue)
    @_setObserver.on 'itemsWereAdded', @_handleItemsAdded.bind(@)
    @_setObserver.on 'itemsWereRemoved', @_handleItemsRemoved.bind(@)
    @_setObserver.startObserving()

  _handleItemsAdded: (items, indexes) ->
    for item in items
      @_addValueInstance(item.get(@key))

  _handleItemsRemoved: (items, indexes) ->
    for item in items
      @_removeValueInstance(item.get(@key))

  _handleItemModified: (item, newValue, oldValue) ->
    @_removeValueInstance(oldValue)
    @_addValueInstance(newValue)

  _addValueInstance: (mappedValue) ->
    @_counter.increment(mappedValue)
    @add(mappedValue)

  _removeValueInstance: (mappedValue) ->
    remaining = @_counter.decrement(mappedValue)
    if remaining is 0
      @remove(mappedValue)

class Batman.SetMapping.PresenceCounter
  constructor: (initialValues) ->
    @_storage = {}
    for value in initialValues
      @increment(value)

  increment: (value) ->
    count = @_storage[value]
    if !count
      @_storage[value] = 1
    else
      @_storage[value] += 1

  decrement: (value) ->
    @_storage[value] -= 1
