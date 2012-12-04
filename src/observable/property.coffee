#= require ./property_event
#= require ../event_emitter/event_emitter
#= require ../set/simple_set

class Batman.Property
  Batman.mixin @prototype, Batman.EventEmitter

  @_sourceTrackerStack: []
  @sourceTracker: -> (stack = @_sourceTrackerStack)[stack.length - 1]
  @defaultAccessor:
    get: (key) -> @[key]
    set: (key, val) -> @[key] = val
    unset: (key) -> x = @[key]; delete @[key]; x
    cache: no
  @defaultAccessorForBase: (base) ->
    base._batman?.getFirst('defaultAccessor') or Batman.Property.defaultAccessor
  @accessorForBaseAndKey: (base, key) ->
    if (_bm = base._batman)?
      accessor = _bm.keyAccessors?.get(key)
      if !accessor
        for ancestor in _bm.ancestors()
          accessor ||= ancestor._batman?.keyAccessors?.get(key)
          break if accessor
    accessor or @defaultAccessorForBase(base)
  @forBaseAndKey: (base, key) ->
    if base.isObservable
      base.property(key)
    else
      new Batman.Keypath(base, key)
  @withoutTracking: (block) -> @wrapTrackingPrevention(block)()
  @wrapTrackingPrevention: (block) ->
    ->
      Batman.Property.pushDummySourceTracker()
      try
        block.apply(@, arguments)
      finally
        Batman.Property.popSourceTracker()
  @registerSource: (obj) ->
    return unless obj.isEventEmitter
    @sourceTracker()?.push(obj)

  @pushSourceTracker: -> Batman.Property._sourceTrackerStack.push([])
  @pushDummySourceTracker: -> Batman.Property._sourceTrackerStack.push(null)
  @popSourceTracker: -> Batman.Property._sourceTrackerStack.pop()

  constructor: (@base, @key) ->
  _isolationCount: 0
  cached: no
  value: null
  sources: null
  isProperty: true
  isDead: false
  eventClass: Batman.PropertyEvent

  isEqual: (other) ->
    @constructor is other.constructor and @base is other.base and @key is other.key
  hashKey: ->
    @hashKey = -> key
    key = "<Batman.Property base: #{Batman.Hash::hashKeyFor(@base)}, key: \"#{Batman.Hash::hashKeyFor(@key)}\">"
  event: (key) ->
    eventClass = @eventClass or Batman.Event
    @events ||= {}
    @events[key] ||= new eventClass(this, key)
    @events[key]
  changeEvent: ->
    event = @event('change')
    @changeEvent = -> event
    event
  accessor: ->
    accessor = @constructor.accessorForBaseAndKey(@base, @key)
    @accessor = -> accessor
    accessor
  eachObserver: (iterator) ->
    key = @key
    iterator(object) for object in @changeEvent().handlers.slice()
    if @base.isObservable
      for ancestor in @base._batman.ancestors()
        if ancestor.isObservable and ancestor.hasProperty(key)
          property = ancestor.property(key)
          handlers = property.changeEvent().handlers
          iterator(object) for object in handlers.slice()
  observers: ->
    results = []
    @eachObserver (observer) -> results.push(observer)
    results
  hasObservers: -> @observers().length > 0

  updateSourcesFromTracker: ->
    newSources = @constructor.popSourceTracker()
    handler = @sourceChangeHandler()
    source?.event('change').removeHandler(handler) for source in @sources if @sources
    @sources = newSources
    source?.event('change').addHandler(handler) for source in @sources if @sources

  getValue: ->
    @registerAsMutableSource()
    unless @isCached()
      @constructor.pushSourceTracker()
      try
        @value = @valueFromAccessor()
        @cached = yes
      finally
        @updateSourcesFromTracker()
    @value

  isCachable: ->
    return true if @isFinal()
    cacheable = @accessor().cache
    if cacheable? then !!cacheable else true

  isCached: -> @isCachable() and @cached

  isFinal: -> !!@accessor()['final']

  refresh: ->
    @cached = no
    previousValue = @value
    value = @getValue()
    if value isnt previousValue and not @isIsolated()
      @fire(value, previousValue)
    @lockValue() if @value isnt undefined and @isFinal()

  sourceChangeHandler: ->
    handler = @_handleSourceChange.bind(@)
    Batman.developer.do => handler.property = @
    @sourceChangeHandler = -> handler
    handler

  _handleSourceChange: ->
    if @isIsolated()
      @_needsRefresh = yes
    else if not @isFinal() && not @hasObservers()
      @cached = no
    else
      @refresh()

  valueFromAccessor: -> @accessor().get?.call(@base, @key)

  setValue: (val) ->
    return unless set = @accessor().set
    @_changeValue -> set.call(@base, @key, val)
  unsetValue: ->
    return unless unset = @accessor().unset
    @_changeValue -> unset.call(@base, @key)

  _changeValue: (block) ->
    @cached = no
    @constructor.pushDummySourceTracker()
    try
      result = block.apply(this)
      @refresh()
    finally
      @constructor.popSourceTracker()
    @die() unless @isCached() or @hasObservers()
    result

  forget: (handler) ->
    if handler?
      @changeEvent().removeHandler(handler)
    else
      @changeEvent().clearHandlers()
  observeAndFire: (handler) ->
    @observe(handler)
    handler.call(@base, @value, @value, @key)
  observe: (handler) ->
    @changeEvent().addHandler(handler)
    @getValue() unless @sources?
    this
  observeOnce: (originalHandler) ->
    event = @changeEvent()
    handler = ->
      originalHandler.apply(@, arguments)
      event.removeHandler(handler)
    event.addHandler(handler)
    @getValue() unless @sources?
    this

  _removeHandlers: ->
    handler = @sourceChangeHandler()
    source.event('change').removeHandler(handler) for source in @sources if @sources
    delete @sources
    @changeEvent().clearHandlers()

  lockValue: ->
    @_removeHandlers()
    @getValue = -> @value
    @setValue = @unsetValue = @refresh = @observe = ->

  die: ->
    @_removeHandlers()
    @base._batman?.properties?.unset(@key)
    @isDead = true

  fire: -> @changeEvent().fire(arguments..., @key)

  isolate: ->
    if @_isolationCount is 0
      @_preIsolationValue = @getValue()
    @_isolationCount++
  expose: ->
    if @_isolationCount is 1
      @_isolationCount--
      if @_needsRefresh
        @value = @_preIsolationValue
        @refresh()
      else if @value isnt @_preIsolationValue
        @fire(@value, @_preIsolationValue)
      @_preIsolationValue = null
    else if @_isolationCount > 0
      @_isolationCount--
  isIsolated: -> @_isolationCount > 0
