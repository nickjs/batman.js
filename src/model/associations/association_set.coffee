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

    if !@foreignKeyValue?
      callback?(undefined, @)
      return Promise.resolve(@)

    @association.getRelatedModel().loadWithOptions loadOptions, (err, records, env) =>
      @markAsLoaded() unless err
      callback?(err, @, env)

  _getLoadOptions: ->
    loadOptions = data: {}
    loadOptions.data[@association.foreignKey] = @foreignKeyValue
    if @association.options.url
      loadOptions.collectionUrl = @association.options.url
      loadOptions.urlContext = @get('parentRecord')
    loadOptions

  markAsLoaded: ->
    @set('loaded', true)
    @fire('loaded')

  @accessor 'parentRecord', ->
    @association.parentSetIndex().get(@foreignKeyValue)

  build: (attrs={}) ->
    initParams = {}
    initParams[@association.foreignKey] = @foreignKeyValue
    options = @association.options
    if options.inverseOf?
      initParams[options.inverseOf] = @get('parentRecord')
    childClass = @association.getRelatedModel()
    mixedAttrs = Batman.extend(initParams, attrs)
    newChild = new childClass(mixedAttrs)
    @add(newChild)
    newChild
