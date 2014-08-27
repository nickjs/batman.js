{Proxy, Property} = require 'foundation'

module.exports = class AssociationProxy extends Proxy
  loaded: false
  @delegatesToTarget 'toJSON', 'destroy', 'save', 'transaction', 'validate'

  constructor: (@association, @model) ->
    super()

  load: (callback) ->
    @fetch (err, proxiedRecord) =>
      unless err
        @_setTarget(proxiedRecord)
      callback?(err, proxiedRecord)

  loadFromLocal: ->
    return unless @_canLoad()
    if target = @fetchFromLocal()
      @_setTarget(target)
    target

  fetch: (callback) ->
    unless @_canLoad()
      callback(undefined, undefined)
      return Promise.reject(undefined)
    if record = @fetchFromLocal()
      callback(undefined, record)
      return Promise.resolve(record)
    else
      new Promise (fulfill, reject) =>
        @fetchFromRemote (err, record) =>
          callback?(err, record)
          if err?
            reject(err)
          else
            fulfill(record)

  @accessor 'loaded', Property.defaultAccessor

  @accessor 'target',
    get: -> @fetchFromLocal()
    set: (_, v) -> v # This just needs to bust the cache

  _canLoad: ->
    (@get('foreignValue') || @get('primaryValue'))?

  _setTarget: (target) ->
    @set 'target', target
    @set 'loaded', true
    @fire 'loaded', target

