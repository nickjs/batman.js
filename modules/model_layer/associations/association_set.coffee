{SetSort, Set, Property, extend} = require 'foundation'

module.exports = class AssociationSet extends SetSort
  constructor: (@foreignKeyValue, @association) ->
    base = new Set
    super(base, '_batmanID')

  loaded: false
  @accessor 'loaded', Property.defaultAccessor

  load: (options, callback) ->
    loadOptions = @_getLoadOptions()
    if !callback
      callback = options
    else
      loadOptions.data = extend(loadOptions.data, options)

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
    mixedAttrs = extend(initParams, attrs)
    newChild = new childClass(mixedAttrs)
    @add(newChild)
    newChild
