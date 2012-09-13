#= require ./association_proxy

class Batman.BelongsToProxy extends Batman.AssociationProxy
  @accessor 'foreignValue', -> @model.get(@association.foreignKey)

  fetchFromLocal: -> @association.setIndex().get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    loadOptions = {}
    loadOptions.recordUrl = @association.options.url if @association.options.url
    @association.getRelatedModel().findWithOptions @get('foreignValue'), loadOptions, (error, loadedRecord) =>
      throw error if error
      callback undefined, loadedRecord
