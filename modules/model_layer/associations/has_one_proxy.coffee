AssociationProxy = require './association_proxy'

module.exports = class HasOneProxy extends AssociationProxy
  @accessor 'primaryValue', -> @model.get(@association.primaryKey)

  fetchFromLocal: -> @association.setIndex().get(@get('primaryValue'))

  fetchFromRemote: (callback) ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @get('primaryValue')
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      loadOptions.urlContext = @model
    @association.getRelatedModel().loadWithOptions loadOptions, (error, loadedRecords) =>
      if !loadedRecords or loadedRecords.length <= 0
        callback(error || new Error("Couldn't find related record!"), undefined)
      else
        callback undefined, loadedRecords[0]
