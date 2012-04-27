#= require binary_set_operation

class Batman.SetUnion extends Batman.BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->  @add items...
  _itemsWereRemovedFromSource: (source, opposite, items...) ->
    itemsToRemove = (item for item in items when !opposite.has(item))
    @remove itemsToRemove...
