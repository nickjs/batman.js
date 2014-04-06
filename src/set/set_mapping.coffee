#= require ./set
#= require ./set_observer
#= require ./set_proxy

class Batman.SetMapping extends Batman.Set
  constructor: (@baseSet, @key) ->
    @base = new Batman.Set
    @_storage = @base._storage
    @base.on 'itemsWereAdded', => @fire 'itemsWereAdded', arguments...
    @base.on 'itemsWereRemoved', => @fire 'itemsWereRemoved', arguments...
    @base.add(@baseSet.mapToProperty(@key)...)

    @_setObserver = new Batman.SetObserver(@baseSet)
    @_setObserver.observedItemKeys = [@key]
    @_setObserver.observerForItemAndKey = (item) => (newValue, oldValue) => @_handleItemModified(item, newValue, oldValue)
    @_setObserver.on 'itemsWereAdded', @_handleItemsAdded.bind(this)
    @_setObserver.on 'itemsWereRemoved', @_handleItemsRemoved.bind(this)
    @_setObserver.startObserving()

  _handleItemsAdded: (items, indexes) ->
    @base.add(item.get(@key)) for item in items

  _handleItemsRemoved: (items, indexes) ->
    @base.remove(item.get(@key)) for item in items

  _handleItemModified: (item, newValue, oldValue) ->
    @base.remove(oldValue)
    @base.add(newValue)

  @accessor 'length', ->
    @registerAsMutableSource()
    @base.get('length')

