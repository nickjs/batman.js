#= require ../../set/set_sort

class Batman.AssociationSet extends Batman.SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Batman.Set
    super(base, '_batmanID')
  loaded: false
  load: (options, callback) ->
    loadOptions = @_getLoadOptions()
    if !callback
      [options, callback] = [{}, options]
    else
      loadOptions.data = Batman.extend(loadOptions.data, options)
    return callback(undefined, @) unless @foreignKeyValue?
    @association.getRelatedModel().loadWithOptions loadOptions, (err, records, env) =>
      @markAsLoaded() unless err
      callback(err, @, env)
  _getLoadOptions: ->
    loadOptions = { data: {} }
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      loadOptions.urlContext = @association.parentSetIndex().get(@foreignKeyValue)
    loadOptions

  @accessor 'loaded', Batman.Property.defaultAccessor
  markAsLoaded: ->
    @set 'loaded', true
    @fire('loaded')
