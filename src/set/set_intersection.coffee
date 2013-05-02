#= require ./binary_set_operation

class Batman.SetIntersection extends Batman.BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    itemsToAdd = (item for item in items when opposite.has(item))
    @add(itemsToAdd...) if itemsToAdd.length > 0
  _itemsWereRemovedFromSource: (source, opposite, items...) -> @remove items...
