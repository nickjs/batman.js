BatmanObject = require '../object/object'
SimpleHash = require '../hash/simple_hash'

module.exports = class SetObserver extends BatmanObject
  constructor: (@base) ->
    @_itemObservers = new SimpleHash
    @_setObservers = new SimpleHash
    @_setObservers.set "itemsWereAdded", => @fire('itemsWereAdded', arguments...)
    @_setObservers.set "itemsWereRemoved", => @fire('itemsWereRemoved', arguments...)
    @on 'itemsWereAdded', @startObservingItems.bind(@)
    @on 'itemsWereRemoved', @stopObservingItems.bind(@)

  observedItemKeys: []
  observerForItemAndKey: (item, key) ->

  _getOrSetObserverForItemAndKey: (item, key) ->
    @_itemObservers.getOrSet item, =>
      observersByKey = new SimpleHash
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
    if item?.isObservable
      for key in @observedItemKeys
        item[method] key, @_getOrSetObserverForItemAndKey(item, key)
      @_itemObservers.unset(item) if method is "forget"

  _manageItemObservers: (method) ->
    @base.forEach (item) => @_manageObserversForItem(item, method)

  _manageSetObservers: (method) ->
    if @base.isObservable
      @_setObservers.forEach (key, observer) =>
        @base.event(key)[method](observer)

