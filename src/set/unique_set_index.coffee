#= require ./set_index

class Batman.UniqueSetIndex extends Batman.SetIndex
  constructor: ->
    @_uniqueIndex = new Batman.Hash
    super

  @accessor (key) -> @_uniqueIndex.get(key)

  _addItems: (key, items) ->
    super
    unless @_uniqueIndex.hasKey(key)
      @_uniqueIndex.set(key, items[0])

  _removeItems: (key, items) ->
    resultSet = super
    if resultSet.isEmpty()
      @_uniqueIndex.unset(key)
    else
      @_uniqueIndex.set(key, resultSet.toArray()[0])
