AbstractCollectionBinding = require './abstract_collection_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class ClassBinding extends AbstractCollectionBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

  constructor: ->
    @existingClasses = arguments[0].node.className.split(' ')
    super

  dataChange: (value) ->
    if value?
      @unbindCollection()

      if typeof value is 'string'
        newClasses = [value].concat(@existingClasses)
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

      existingClasses = @existingClasses.slice(0)
      newClasses = array.filter (val) ->
        existingClasses.indexOf(val) == -1

      @node.className = existingClasses.concat(newClasses).join(' ').trim()

  handleArrayChanged: => @updateFromCollection()
