#= require ./abstract_attribute_binding

class Batman.DOM.AbstractCollectionBinding extends Batman.DOM.AbstractAttributeBinding

  bindCollection: (newCollection) ->
    unless newCollection == @collection
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

