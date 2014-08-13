{Hash} = require 'foundation'
AbstractAttributeBinding = require './abstract_attribute_binding'

module.exports = class AbstractCollectionBinding extends AbstractAttributeBinding

  dataChange: (collection) ->
    if collection?
      unless @bindCollection(collection)
        items = if collection?.forEach
          _items = []
          collection.forEach (item) -> _items.push item
          _items
        else
          Object.keys(collection)
        @handleArrayChanged(items)
    else
      @unbindCollection()
      @collection = []
      @handleArrayChanged([])
    return

  bindCollection: (newCollection) ->
    if newCollection instanceof Hash
      newCollection = newCollection.meta # Get the object which will  have a toArray
    if newCollection == @collection
      return true
    else
      @unbindCollection()
      @collection = newCollection

      return false unless @collection?.isObservable

      if @collection.isCollectionEventEmitter and @handleItemsAdded and @handleItemsRemoved and @handleItemMoved
        @collection.on('itemsWereAdded', @handleItemsAdded)
        @collection.on('itemsWereRemoved', @handleItemsRemoved)
        @collection.on('itemWasMoved', @handleItemMoved)

        @handleArrayChanged(@collection.toArray())
      else
        @collection.observeAndFire('toArray', @handleArrayChanged)

      return true

  unbindCollection: ->
    return unless @collection?.isObservable

    if @collection.isCollectionEventEmitter and @handleItemsAdded and @handleItemsRemoved and @handleItemMoved
      @collection.off('itemsWereAdded', @handleItemsAdded)
      @collection.off('itemsWereRemoved', @handleItemsRemoved)
      @collection.off('itemWasMoved', @handleItemMoved)
    else
      @collection.forget('toArray', @handleArrayChanged)

  handleArrayChanged: ->

  die: ->
    @unbindCollection()
    @collection = null
    super

