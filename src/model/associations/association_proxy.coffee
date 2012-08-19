#= require ../../handy/proxy

class Batman.AssociationProxy extends Batman.Proxy
  loaded: false
  constructor: (@association, @model) ->
    super()

  toJSON: ->
    target = @get('target')
    @get('target').toJSON() if target?

  load: (callback) ->
    @fetch (err, proxiedRecord) =>
      unless err
        @set 'loaded', true
        @set 'target', proxiedRecord
      callback?(err, proxiedRecord)
    @get('target')

  fetch: (callback) ->
    unless (@get('foreignValue') || @get('primaryValue'))?
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
