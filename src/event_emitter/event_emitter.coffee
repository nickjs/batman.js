#= require ./event

Batman.EventEmitter =
  isEventEmitter: true
  hasEvent: (key) ->
    @_batman?.get?('events')?.hasOwnProperty(key)
  event: (key) ->
    Batman.initializeObject @
    eventClass = @eventClass or Batman.Event
    events = @_batman.events ||= {}
    if events.hasOwnProperty(key)
      existingEvent = events[key]
    else
      @_batman.ancestors (ancestor) ->
        existingEvent ||= ancestor._batman?.events?[key]
      newEvent = events[key] = new eventClass(this, key)
      newEvent.oneShot = existingEvent?.oneShot
      newEvent
  on: (key, handler) ->
    @event(key).addHandler(handler)
  once: (key, originalHandler) ->
    event = @event(key)
    handler = ->
      originalHandler.apply(@, arguments)
      event.removeHandler(handler)
    event.addHandler(handler)
  registerAsMutableSource: ->
    Batman.Property.registerSource(@)
  mutation: (wrappedFunction) ->
    ->
      result = wrappedFunction.apply(this, arguments)
      @event('change').fire(this, this)
      result
  prevent: (key) ->
    @event(key).prevent()
    @
  allow: (key) ->
    @event(key).allow()
    @
  isPrevented: (key) ->
    @event(key).isPrevented()
  fire: (key, args...) ->
    @event(key).fire(args...)
  allowAndFire: (key, args...) ->
    @event(key).allowAndFire(args...)
