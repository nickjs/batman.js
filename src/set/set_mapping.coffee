#= require ./set
#= require ./set_observer
#= require ./set_proxy

class Batman.SetMapping extends Batman.Set
  constructor: (@base, @key) ->
    # Set's constructor ignores null/undefined (via SimpleSet), hence adding later.
    super()
    @add(@base.mapToProperty(@key)...)

    @_setObserver = new Batman.SetObserver(@base)
    @_setObserver.observedItemKeys = [@key]
    @_setObserver.observerForItemAndKey = (item) => (newValue, oldValue) => @_handleItemModified(item, newValue, oldValue)
    @_setObserver.on 'itemsWereAdded', @_handleItemsAdded.bind(this)
    @_setObserver.on 'itemsWereRemoved', @_handleItemsRemoved.bind(this)
    @_setObserver.startObserving()

  _handleItemsAdded: (items, indexes) ->
    @add(item.get(@key)) for item in items

  _handleItemsRemoved: (items, indexes) ->
    @remove(item.get(@key)) for item in items

  _handleItemModified: (item, newValue, oldValue) ->
    @remove(oldValue)
    @add(newValue)
