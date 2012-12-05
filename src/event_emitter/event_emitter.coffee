#= require ./event

Batman.EventEmitter =
  isEventEmitter: true
  hasEvent: (key) ->
    @_batman?.get?('events')?.hasOwnProperty(key)
  event: (key, copy = true) ->
    Batman.initializeObject this
    eventClass = @eventClass or Batman.Event
    events = @_batman.events ||= {}
    if events.hasOwnProperty(key)
      existingEvent = events[key]
    else
      for ancestor in @_batman.ancestors()
        existingEvent = ancestor._batman?.events?[key]
        break if existingEvent
      if copy
        newEvent = events[key] = new eventClass(this, key)
        newEvent.oneShot = existingEvent?.oneShot
        newEvent
      else
        existingEvent

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
      @event('change', false)?.fire(this, this)
      result
  prevent: (key) ->
    @event(key).prevent()
    this
  allow: (key) ->
    @event(key).allow()
    this
  isPrevented: (key) ->
    @event(key, false)?.isPrevented()
  fire: (key, args...) ->
    @event(key, false)?.fire(args...)
  allowAndFire: (key, args...) ->
    @event(key, false)?.allowAndFire(args...)
