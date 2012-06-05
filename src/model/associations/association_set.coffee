#= require ../../set/set_sort

class Batman.AssociationSet extends Batman.SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Batman.Set
    super(base, 'hashKey')
  loaded: false
  load: (callback) ->
    return callback(undefined, @) unless @foreignKeyValue?
    @association.getRelatedModel().load @_getLoadOptions(), (err, records) =>
      unless err
        @set 'loaded', true
        @loaded = true
      @fire 'loaded'
      callback(err, @)
  _getLoadOptions: ->
    loadOptions = {}
    loadOptions[@association.foreignKey] = @foreignKeyValue
    loadOptions

  @accessor 'loaded', Batman.Property.defaultAccessor
