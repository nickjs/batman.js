class Batman.SetObserver extends Batman.Object
  constructor: (@base) ->
    @_itemObservers = new Batman.SimpleHash
    @_setObservers = new Batman.SimpleHash
    @_setObservers.set "itemsWereAdded", => @fire('itemsWereAdded', arguments)
    @_setObservers.set "itemsWereRemoved", => @fire('itemsWereRemoved', arguments)
    @on 'itemsWereAdded', @startObservingItems.bind(@)
    @on 'itemsWereRemoved', @stopObservingItems.bind(@)

  observedItemKeys: []
  observerForItemAndKey: (item, key) ->

  _getOrSetObserverForItemAndKey: (item, key) ->
    @_itemObservers.getOrSet item, =>
      observersByKey = new Batman.SimpleHash
      observersByKey.getOrSet key, =>
        @observerForItemAndKey(item, key)
  startObserving: ->
    @_manageItemObservers("observe")
    @_manageSetObservers("addHandler")
  stopObserving: ->
    @_manageItemObservers("forget")
    @_manageSetObservers("removeHandler")
  startObservingItems: (items) ->
    @_manageObserversForItem(item, "observe") for item in items
    return
  stopObservingItems: (items) ->
    @_manageObserversForItem(item, "forget") for item in items
    return
  _manageObserversForItem: (item, method) ->
    return unless item.isObservable
    for key in @observedItemKeys
      item[method] key, @_getOrSetObserverForItemAndKey(item, key)
    @_itemObservers.unset(item) if method is "forget"
  _manageItemObservers: (method) ->
    @base.forEach (item) => @_manageObserversForItem(item, method)
  _manageSetObservers: (method) ->
    return unless @base.isObservable
    @_setObservers.forEach (key, observer) =>
      @base.event(key)[method](observer)
