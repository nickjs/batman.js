SetIndex = require './set_index'
Hash = require '../hash/hash'

module.exports = class UniqueSetIndex extends SetIndex
  constructor: ->
    @_uniqueIndex = new Hash
    super

  @accessor (key) -> @_uniqueIndex.get(key)

  _addItemsToKey: (key, items) ->
    super
    unless @_uniqueIndex.hasKey(key)
      @_uniqueIndex.set(key, items[0])

  _removeItemsFromKey: (key, items) ->
    resultSet = super
    if resultSet.isEmpty()
      @_uniqueIndex.unset(key)
    else
      @_uniqueIndex.set(key, resultSet._storage[0])
