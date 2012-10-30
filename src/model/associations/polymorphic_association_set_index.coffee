#= require ../../set/set_index

class Batman.PolymorphicAssociationSetIndex extends Batman.SetIndex
  constructor: (@association, @type, key) ->
    super @association.getRelatedModelForType(type).get('loaded'), key

  _resultSetForKey: (key) -> @association.setForKey(key)

  _addItem: (item) -> 
    return unless @association.modelType() is item.get(@association.foreignTypeKey)
    super

  _removeItem: (item) -> 
    return unless @association.modelType() is item.get(@association.foreignTypeKey)
    super
