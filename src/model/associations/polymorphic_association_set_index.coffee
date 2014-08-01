#= require ../../set/set_index

class Batman.PolymorphicAssociationSetIndex extends Batman.SetIndex
  constructor: (@association, @type, key) ->
    super @association.getRelatedModel().get('loaded'), key

  _resultSetForKey: (key) -> @association.setForKey(key)

  _addItemsToKey: (key, items) ->
    super(key, @_filteredItems(items))

  _removeItemsFromKey: (key, items) ->
    super(key, @_filteredItems(items))

  _filteredItems: (items) ->
    # only handle items for @type
    item for item in items when @type is item.get(@association.foreignTypeKey)