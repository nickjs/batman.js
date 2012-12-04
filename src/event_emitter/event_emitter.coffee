#= require ./event

Batman.EventEmitter =
  isEventEmitter: true
  hasEvent: (key) ->
    @_batman?.get?('events')?.hasOwnProperty(key)
  event: (key) ->
    Batman.initializeObject this
    eventClass = @eventClass or Batman.Event
    events = @_batman.events ||= {}
    if events.hasOwnProperty(key)
      existingEvent = events[key]
    else
      for ancestor in @_batman.ancestors()
        existingEvent = ancestor._batman?.events?[key]
        break if existingEvent
      newEvent = events[key] = new eventClass(this, key)
      newEvent.oneShot = existingEvent?.oneShot
      newEvent
  on: (keys..., handler) ->
    @event(key).addHandler(handler) for key in keys
  once: (key, handler) ->
    event = @event(key)
    handlerWrapper = ->
      handler.apply(this, arguments)
      event.removeHandler(handlerWrapper)
    event.addHandler(handlerWrapper)
  registerAsMutableSource: ->
    Batman.Property.registerSource(this)
  mutation: (wrappedFunction) ->
    ->
      result = wrappedFunction.apply(this, arguments)
      @event('change').fire(this, this)
      result
  prevent: (key) ->
    @event(key).prevent()
    this
  allow: (key) ->
    @event(key).allow()
    this
  isPrevented: (key) ->
    @event(key).isPrevented()
  fire: (key, args...) ->
    @event(key).fire(args...)
  allowAndFire: (key, args...) ->
    @event(key).allowAndFire(args...)
