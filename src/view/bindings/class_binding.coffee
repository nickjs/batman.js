#= require ./abstract_collection_binding

class Batman.DOM.ClassBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  # set the 'master list' of classes that exist on the node
  constructor: () ->
    # using classList may be a better option in the future when it is more widely
    # suppoerted, however for now we'll have to use className

    @existingClasses = arguments[0].node.className.split(' ')
    super

  dataChange: (value) ->

    if value?
      @unbindCollection()
      if typeof value is 'string'

        # create a new list of classes that merges existingClasses, then push
        # the newly added class, join the list and re-apply the classes
        newClasses = [].concat(@existingClasses)
        newClasses.push value

        # NOTE: i considered adding something that would go through and .trim()
        # each string in the array, but decided that should be up to the user to
        # format their strings correctly
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

      # create a new list of classes that merges existingClasses, then filter
      # the new classes to be applied, removing any that already exist, concat
      # the arrays, join them, and re-apply the classes
      existingClasses = [].concat @existingClasses
      newClasses = array.filter (val) ->
        existingClasses.indexOf(val) == -1

      # NOTE: i considered adding something that would go through and .trim()
      # each string in the array, but decided that should be up to the user to
      # format their strings correctly
      @node.className = existingClasses.concat(newClasses).join(' ').trim()

  handleArrayChanged: => @updateFromCollection()
