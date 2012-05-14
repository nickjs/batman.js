#= require ./association_proxy

class Batman.BelongsToProxy extends Batman.AssociationProxy
  @accessor 'foreignValue', -> @model.get(@association.foreignKey)

  fetchFromLocal: -> @association.setIndex().get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    @association.getRelatedModel().find @get('foreignValue'), (error, loadedRecord) =>
      throw error if error
      callback undefined, loadedRecord
