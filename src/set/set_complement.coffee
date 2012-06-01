#= require ./binary_set_operation

class Batman.SetComplement extends Batman.BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    if source == @left
      itemsToAdd = (item for item in items when not opposite.has(item))
      @add itemsToAdd...
    else
      itemsToRemove = (item for item in items when opposite.has(item))
      @remove itemsToRemove...

  _itemsWereRemovedFromSource: (source, opposite, items...) ->
    if source == @left
      @remove items...
    else
      itemsToAdd = (item for item in items when opposite.has(item))
      @add itemsToAdd...

  _addComplement: (items, opposite) ->
    @add (item for item in items when opposite.has(item))...

#= require ./binary_set_operation

#class Batman.SetComplement extends Batman.BinarySetOperation
  #_itemsWereAddedToSource: (source, opposite, items...) ->
    #if source == @left
      #@_addComplement(items, opposite)
    #else
      #itemsToRemove = (item for item in items when opposite.has(item))
      #@remove itemsToRemove...

  #_itemsWereRemovedFromSource: (source, opposite, items...) ->
    #if source == @left
      #@remove items...
    #else
      #@_addComplement(items, opposite)




