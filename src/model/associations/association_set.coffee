#= require ../../set/set_sort

class Batman.AssociationSet extends Batman.SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Batman.Set
    super(base, '_batmanID')

  loaded: false
  @accessor 'loaded', Batman.Property.defaultAccessor

  load: (options, callback) ->
    loadOptions = @_getLoadOptions()
    if !callback
      callback = options
    else
      loadOptions.data = Batman.extend(loadOptions.data, options)

    return callback(undefined, @) unless @foreignKeyValue?
    @association.getRelatedModel().loadWithOptions loadOptions, (err, records, env) =>
      @markAsLoaded() unless err

      callback(err, @, env)

  _getLoadOptions: ->
    loadOptions = data: {}
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      loadOptions.urlContext = @association.parentSetIndex().get(@foreignKeyValue)
    loadOptions

  markAsLoaded: ->
    @set('loaded', true)
    @fire('loaded')

  @accessor 'parentRecord', ->
    parentClass =  @get('association.model')
    parentPrimaryKey = parentClass.get('primaryKey')
    parentPrimaryKeyValue = @get('foreignKeyValue')
    query = {}
    query[parentPrimaryKey] = parentPrimaryKeyValue
    # pull it from the identity map, if it's there:
    parentClass.createFromJSON(query)

  build: (attrs={}) ->
    initParams = {}
    initParams[@get('association.foreignKey')] = @get('foreignKeyValue')
    options = @get('association.options')
    if options.inverseOf?
      initParams[options.inverseOf] = @get('parentRecord')
    associatedClass = options.namespace[options.name]
    mixedAttrs = Batman.extend(attrs, initParams)
    newObj = new associatedClass(mixedAttrs)
    @add(newObj)
    newObj
