#= require ./set_index

class Batman.UniqueSetIndex extends Batman.SetIndex
  constructor: ->
    @_uniqueIndex = new Batman.Hash
    super
  @accessor (key) -> @_uniqueIndex.get(key)
  _addItemToKey: (item, key) ->
    @_resultSetForKey(key).add item
    unless @_uniqueIndex.hasKey(key)
      @_uniqueIndex.set(key, item)
  _removeItemFromKey: (item, key) ->
    resultSet = @_resultSetForKey(key)
    super
    if resultSet.isEmpty()
      @_uniqueIndex.unset(key)
    else
      @_uniqueIndex.set(key, resultSet.toArray()[0])
