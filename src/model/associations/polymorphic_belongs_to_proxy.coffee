#= require belongs_to_proxy

class Batman.PolymorphicBelongsToProxy extends Batman.BelongsToProxy
  @accessor 'foreignTypeValue', -> @model.get(@association.foreignTypeKey)

  fetchFromLocal: ->
    @association.setIndexForType(@get('foreignTypeValue')).get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    @association.getRelatedModelForType(@get('foreignTypeValue')).find @get('foreignValue'), (error, loadedRecord) =>
      throw error if error
      callback undefined, loadedRecord
