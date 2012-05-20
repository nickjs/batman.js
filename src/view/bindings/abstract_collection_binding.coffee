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
      if @collection?.isObservable
        @collection.observeAndFire 'toArray', @handleArrayChanged
        return true
    return false

  unbindCollection: ->
    if @collection?.isObservable
      @collection.forget('toArray', @handleArrayChanged)

  handleArrayChanged: ->

  die: ->
    @unbindCollection()
    super

