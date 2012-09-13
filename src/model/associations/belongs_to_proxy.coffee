#= require ./association_proxy

class Batman.BelongsToProxy extends Batman.AssociationProxy
  @accessor 'foreignValue', -> @model.get(@association.foreignKey)

  fetchFromLocal: -> @association.setIndex().get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    loadOptions = {}
    loadOptions.recordUrl = @association.options.customUrl if @association.options.customUrl
    @association.getRelatedModel().findWithOptions @get('foreignValue'), loadOptions, (error, loadedRecord) =>
      throw error if error
      callback undefined, loadedRecord
