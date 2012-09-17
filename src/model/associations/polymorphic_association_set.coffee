#= require ./association_set

class Batman.PolymorphicAssociationSet extends Batman.AssociationSet
  constructor: (@foreignKeyValue, @foreignTypeKeyValue, @association) ->
    super(@foreignKeyValue, @association)

  _getLoadOptions: ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    loadOptions.data[@association.foreignTypeKey] = @foreignTypeKeyValue
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      loadOptions.urlContext = @association.parentSetIndex().get(@foreignKeyValue)
    loadOptions
