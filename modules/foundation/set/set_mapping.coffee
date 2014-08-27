SetObserver = require './set_observer'
Set = require './set'
SimpleHash = require '../hash/simple_hash'

module.exports = class SetMapping extends Set
  constructor: (@base, @key) ->
    initialValues = @base.mapToProperty(@key)
    @_counter = new @constructor.PresenceCounter(initialValues)
    super(initialValues)
    @_setObserver = new SetObserver(@base)
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

class SetMapping.PresenceCounter
  constructor: (initialValues) ->
    @_storage = new SimpleHash
    for value in initialValues
      @increment(value)

  increment: (value) ->
    count = @_storage.get(value)
    if !count
      @_storage.set value, 1
    else
      @_storage.set value, count + 1

  decrement: (value) ->
    count = @_storage.get(value)
    @_storage.set value, count - 1
