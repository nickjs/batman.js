#= require binary_set_operation

class Batman.SetIntersection extends Batman.BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    itemsToAdd = (item for item in items when opposite.has(item))
    @add itemsToAdd...
  _itemsWereRemovedFromSource: (source, opposite, items...) -> @remove items...
