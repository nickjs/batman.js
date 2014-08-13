AssociationProxy = require './association_proxy'

module.exports = class BelongsToProxy extends AssociationProxy
  @accessor 'foreignValue', -> @model.get(@association.foreignKey)

  fetchFromLocal: -> @association.setIndex().get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    loadOptions = {}
    loadOptions.recordUrl = @association.options.url if @association.options.url
    @association.getRelatedModel().findWithOptions @get('foreignValue'), loadOptions, callback
