#= require ../../utilities/proxy

class Batman.AssociationProxy extends Batman.Proxy
  loaded: false
  constructor: (@association, @model) ->
    super()
    @delegatesToTarget('destroy', 'save', 'validate')

  toJSON: ->
    target = @get('target')
    @get('target').toJSON() if target?

  load: (callback) ->
    @fetch (err, proxiedRecord) =>
      unless err
        @_setTarget(proxiedRecord)
      callback?(err, proxiedRecord)
    @get('target')

  loadFromLocal: ->
    return unless @_canLoad()
    if target = @fetchFromLocal()
      @_setTarget(target)
    target

  fetch: (callback) ->
    unless @_canLoad()
      return callback(undefined, undefined)
    record = @fetchFromLocal()
    if record
      return callback(undefined, record)
    else
      @fetchFromRemote(callback)

  @accessor 'loaded', Batman.Property.defaultAccessor

  @accessor 'target',
    get: -> @fetchFromLocal()
    set: (_, v) -> v # This just needs to bust the cache

  _canLoad: ->
    (@get('foreignValue') || @get('primaryValue'))?

  _setTarget: (target) ->
    @set 'target', target
    @set 'loaded', true
    @fire 'loaded', target

