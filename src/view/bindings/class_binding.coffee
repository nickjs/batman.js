#= require ./abstract_collection_binding

class Batman.DOM.ClassBinding extends Batman.DOM.AbstractCollectionBinding
  dataChange: (value) ->
    if value?
      @unbindCollection()
      if typeof value is 'string'
        @node.className = value
      else
        @bindCollection(value)
        @updateFromCollection()

  updateFromCollection: ->
    if @collection
      array = if @collection.map
        @collection.map((x) -> x)
      else
        (k for own k,v of @collection)
      array = array.toArray() if array.toArray?
      @node.className = array.join ' '

  handleArrayChanged: => @updateFromCollection()
