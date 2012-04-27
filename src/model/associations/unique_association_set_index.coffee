#= require ../../set/unique_set_index

class Batman.UniqueAssociationSetIndex extends Batman.UniqueSetIndex
  constructor: (@association, key) ->
    super @association.getRelatedModel().get('loaded'), key
