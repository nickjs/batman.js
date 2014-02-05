#= require ./abstract_collection_binding

class Batman.DOM.ClassBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: () ->
    @existingClasses = arguments[0].node.className.split(' ')
    super

  dataChange: (value) ->
    if value?
      @unbindCollection()
      if typeof value is 'string'

        newClasses = [].concat(@existingClasses)
        newClasses.push value

        @node.className = newClasses.join(' ').trim()
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

      existingClasses = [].concat @existingClasses
      newClasses = array.filter (val) ->
        existingClasses.indexOf(val) == -1

      @node.className = existingClasses.concat(newClasses).join(' ').trim()

  handleArrayChanged: => @updateFromCollection()