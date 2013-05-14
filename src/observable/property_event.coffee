#= require ../event_emitter/event

class Batman.PropertyEvent extends Batman.Event
  eachHandler: (iterator) -> @eachObserver(iterator)
  handlerContext: -> @base
