#= require ./abstract_attribute_binding

class Batman.DOM.AbstractCollectionBinding extends Batman.DOM.AbstractAttributeBinding

  bindCollection: (newCollection) ->
    unless newCollection == @collection
      @unbindCollection()
      @collection = newCollection
      if @collection
        if @collection.isObservable && @collection.toArray
          @collection.observe 'toArray', @handleArrayChanged
        else if @collection.isEventEmitter
          @collection.on 'itemsWereAdded', @handleItemsWereAdded
          @collection.on 'itemsWereRemoved', @handleItemsWereRemoved
        else
          return false
        return true
    return false

  unbindCollection: ->
    if @collection
      if @collection.isObservable && @collection.toArray
        @collection.forget('toArray', @handleArrayChanged)
      else if @collection.isEventEmitter
        @collection.event('itemsWereAdded').removeHandler(@handleItemsWereAdded)
        @collection.event('itemsWereRemoved').removeHandler(@handleItemsWereRemoved)

  handleItemsWereAdded: ->
  handleItemsWereRemoved: ->
  handleArrayChanged: ->

  die: ->
    @unbindCollection()
    super

