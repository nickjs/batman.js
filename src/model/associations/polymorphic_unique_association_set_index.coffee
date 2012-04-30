class Batman.PolymorphicUniqueAssociationSetIndex extends Batman.UniqueSetIndex
  constructor: (@association, @type, key) ->
    super @association.getRelatedModelForType(type).get('loaded'), key
