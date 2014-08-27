BinarySetOperation = require './binary_set_operation'

module.exports = class SetComplement extends BinarySetOperation
  _itemsWereAddedToSource: (source, opposite, items...) ->
    if source == @left
      itemsToAdd = (item for item in items when not opposite.has(item))
      @addArray(itemsToAdd) if itemsToAdd.length > 0
    else
      itemsToRemove = (item for item in items when opposite.has(item))
      @removeArray(itemsToRemove) if itemsToRemove.length > 0

  _itemsWereRemovedFromSource: (source, opposite, items...) ->
    if source == @left
      @removeArray(items)
    else
      itemsToAdd = (item for item in items when opposite.has(item))
      @addArray(itemsToAdd) if itemsToAdd.length > 0

  _addComplement: (items, opposite) ->
    itemsToAdd = (item for item in items when opposite.has(item))
    @addArray(itemsToAdd) if itemsToAdd.length > 0
