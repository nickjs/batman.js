#= require ./binary_set_operation

class Batman.SetComplement extends Batman.BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    if source == @left
      itemsToAdd = (item for item in items when not opposite.has(item))
      @add(itemsToAdd...) if itemsToAdd.length > 0
    else
      itemsToRemove = (item for item in items when opposite.has(item))
      @remove(itemsToRemove...) if itemsToRemove.length > 0

  _itemsWereRemovedFromSource: (source, opposite, items...) ->
    if source == @left
      @remove items...
    else
      itemsToAdd = (item for item in items when opposite.has(item))
      @add(itemsToAdd...) if itemsToAdd.length > 0

  _addComplement: (items, opposite) ->
    itemsToAdd = (item for item in items when opposite.has(item))
    @add(itemsToAdd...) if itemsToAdd.length > 0
