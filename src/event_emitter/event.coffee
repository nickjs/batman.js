class Batman.Event
  @forBaseAndKey: (base, key) ->
    if base.isEventEmitter
      base.event(key)
    else
      new Batman.Event(base, key)
  constructor: (@base, @key) ->
    @handlers = []
    @_preventCount = 0
  isEvent: true
  isEqual: (other) ->
    @constructor is other.constructor and @base is other.base and @key is other.key
  hashKey: ->
    @hashKey = -> key
    key = "<Batman.Event base: #{Batman.Hash::hashKeyFor(@base)}, key: \"#{Batman.Hash::hashKeyFor(@key)}\">"
  addHandler: (handler) ->
    @handlers.push(handler) if @handlers.indexOf(handler) == -1
    @autofireHandler(handler) if @oneShot
    this
  removeHandler: (handler) ->
    if (index = @handlers.indexOf(handler)) != -1
      @handlers.splice(index, 1)
    this
  eachHandler: (iterator) ->
    @handlers.slice().forEach(iterator)
    if @base?.isEventEmitter
      key = @key
      for ancestor in @base._batman?.ancestors()
        if ancestor.isEventEmitter and ancestor._batman?.events?.hasOwnProperty(key)
          handlers = ancestor.event(key, false)?.handlers
          handlers?.slice().forEach(iterator)
  clearHandlers: -> @handlers = []
  handlerContext: -> @base
  prevent: -> ++@_preventCount
  allow: ->
    --@_preventCount if @_preventCount
    @_preventCount
  isPrevented: -> @_preventCount > 0
  autofireHandler: (handler) ->
    if @_oneShotFired and @_oneShotArgs?
      handler.apply(@handlerContext(), @_oneShotArgs)
  resetOneShot: ->
    @_oneShotFired = false
    @_oneShotArgs = null
  fire: ->
    @fireWithContext(@handlerContext(), arguments...)
  fireWithContext: (context, args...) ->
    return false if @isPrevented() or @_oneShotFired
    if @oneShot
      @_oneShotFired = true
      @_oneShotArgs = args
    @eachHandler (handler) -> handler.apply(context, args)
  allowAndFire: ->
    @allowAndFireWithContext(@handlerContext, arguments...)
  allowAndFireWithContext: (context, args...) ->
    @allow()
    @fireWithContext(context, args...)
