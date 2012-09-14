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
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      console.log @association.setIndex(), @foreignKeyValue
      loadOptions.urlContext = @association.parentSetIndex().get(@foreignKeyValue)
    loadOptions

  @accessor 'loaded', Batman.Property.defaultAccessor
  markAsLoaded: ->
    @set 'loaded', true
    @fire('loaded')
