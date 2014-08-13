BinarySetOperation = require './binary_set_operation'


module.exports = class SetUnion extends BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->  @addArray(items)
  _itemsWereRemovedFromSource: (source, opposite, items...) ->
    itemsToRemove = (item for item in items when !opposite.has(item))
    @removeArray(itemsToRemove)
