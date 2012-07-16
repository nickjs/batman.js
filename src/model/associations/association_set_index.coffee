#= require ../../set/set_index

class Batman.AssociationSetIndex extends Batman.SetIndex
  constructor: (@association, key) ->
    super @association.getRelatedModel().get('loaded'), key

  _resultSetForKey: (key) ->
    @_storage.getOrSet key, =>
      new @association.proxyClass(key, @association)

  _setResultSet: (key, set) ->
    @_storage.set key, set

