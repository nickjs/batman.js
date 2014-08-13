BinarySetOperation = require './binary_set_operation'

module.exports = class SetIntersection extends BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    itemsToAdd = (item for item in items when opposite.has(item))
    @addArray(itemsToAdd) if itemsToAdd.length > 0
  _itemsWereRemovedFromSource: (source, opposite, items...) -> @removeArray(items)
