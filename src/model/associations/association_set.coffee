#= require ../../set/set_sort

class Batman.AssociationSet extends Batman.SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Batman.Set
    super(base, '_batmanID')
  loaded: false
  load: (callback) ->
    return callback(undefined, @) unless @foreignKeyValue?
    @association.getRelatedModel().loadWithOptions @_getLoadOptions(), (err, records) =>
      @markAsLoaded() unless err
      callback(err, @)
  _getLoadOptions: ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    loadOptions.collectionUrl = @association.options.customUrl if @association.options.customUrl
    loadOptions

  @accessor 'loaded', Batman.Property.defaultAccessor
  markAsLoaded: ->
    @set 'loaded', true
    @fire('loaded')
