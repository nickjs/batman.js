#= require ./abstract_attribute_binding

class Batman.DOM.AbstractCollectionBinding extends Batman.DOM.AbstractAttributeBinding

  bindCollection: (newCollection) ->
    if newCollection instanceof Batman.Hash
      newCollection = newCollection.meta # Get the object which will  have a toArray
    if newCollection == @collection
      return true
    else
      @unbindCollection()
      @collection = newCollection

      return false unless @collection?.isObservable

      if @collection.isCollectionEventEmitter and @handleItemsAdded and @handleItemsRemoved
        @collection.on('itemsWereAdded', @handleItemsAdded)
        @collection.on('itemsWereRemoved', @handleItemsRemoved)

        @handleArrayChanged(@collection.toArray()) if @collection.length

      else
        @collection.observeAndFire('toArray', @handleArrayChanged)

      return true

  unbindCollection: ->
    return unless @collection?.isObservable

    if @collection.isCollectionEventEmitter and @handleItemsAdded and @handleItemsRemoved
      @collection.off('itemsWereAdded', @handleItemsAdded)
      @collection.off('itemsWereRemoved', @handleItemsRemoved)
    else
      @collection.off('toArray', @handleArrayChanged)

  handleArrayChanged: ->

  die: ->
    @unbindCollection()
    @collection = null
    super

