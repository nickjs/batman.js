#= require ./association_set

class Batman.PolymorphicAssociationSet extends Batman.AssociationSet
  constructor: (@foreignKeyValue, @foreignTypeKeyValue, @association) ->
    super(@foreignKeyValue, @association)

  _getLoadOptions: ->
    loadOptions = {}
    loadOptions[@association.foreignKey] = @foreignKeyValue
    loadOptions[@association.foreignTypeKey] = @foreignTypeKeyValue
    loadOptions
