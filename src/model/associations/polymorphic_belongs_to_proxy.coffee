#= require ./belongs_to_proxy

class Batman.PolymorphicBelongsToProxy extends Batman.BelongsToProxy
  @accessor 'foreignTypeValue', -> @model.get(@association.foreignTypeKey)

  fetchFromLocal: ->
    @association.setIndexForType(@get('foreignTypeValue')).get(@get('foreignValue'))

  fetchFromRemote: (callback) ->
    loadOptions = {}
    loadOptions.recordUrl = @association.options.url if @association.options.url
    @association.getRelatedModelForType(@get('foreignTypeValue')).findWithOptions @get('foreignValue'), loadOptions, callback
