#= require ./association_proxy

class Batman.HasOneProxy extends Batman.AssociationProxy
  @accessor 'primaryValue', -> @model.get(@association.primaryKey)

  fetchFromLocal: -> @association.setIndex().get(@get('primaryValue'))

  fetchFromRemote: (callback) ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @get('primaryValue')
    loadOptions.collectionUrl = @association.options.url if @association.options.url
    @association.getRelatedModel().loadWithOptions loadOptions, (error, loadedRecords) =>
      throw error if error
      if !loadedRecords or loadedRecords.length <= 0
        callback new Error("Couldn't find related record!"), undefined
      else
        callback undefined, loadedRecords[0]
