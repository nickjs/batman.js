#= require ./set_index

class Batman.UniqueSetIndex extends Batman.SetIndex
  constructor: ->
    @_uniqueIndex = new Batman.Hash
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
