#= require ../../set/set_index

class Batman.PolymorphicAssociationSetIndex extends Batman.SetIndex
  constructor: (@association, @type, key) ->
    super @association.getRelatedModel().get('loaded'), key

  _resultSetForKey: (key) -> @association.setForKey(key)

  _addItemsToKey: (key, items) ->
    filteredItems = (item for item in items when @association.modelType() is item.get(@association.foreignTypeKey))
    super(key, filteredItems)

  _removeItemsFromKey: (key, items) ->
    filteredItems = (item for item in items when @association.modelType() is item.get(@association.foreignTypeKey))
    super(key, filteredItems)
