#= require ../../set/set_sort

class Batman.AssociationSet extends Batman.SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Batman.Set
    super(base, 'hashKey')
  loaded: false
  load: (callback) ->
    return callback(undefined, @) unless @foreignKeyValue?
    @association.getRelatedModel().load @_getLoadOptions(), (err, records) =>
      @markAsLoaded() unless err
      callback(err, @)
  _getLoadOptions: ->
    loadOptions = {}
    loadOptions[@association.foreignKey] = @foreignKeyValue
    loadOptions

  @accessor 'loaded', Batman.Property.defaultAccessor
  markAsLoaded: ->
    @set 'loaded', true
    @fire('loaded')
