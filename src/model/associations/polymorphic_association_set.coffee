#= require ./association_set

class Batman.PolymorphicAssociationSet extends Batman.AssociationSet
  constructor: (@foreignKeyValue, @foreignTypeKeyValue, @association) ->
    super(@foreignKeyValue, @association)

  _getLoadOptions: ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    loadOptions.data[@association.foreignTypeKey] = @foreignTypeKeyValue
    loadOptions.collectionUrl = @association.options.customUrl if @association.options.customUrl
    loadOptions
