#= require ../event_emitter/event

class Batman.PropertyEvent extends Batman.Event
  eachHandler: (iterator) -> @base.eachObserver(iterator)
  handlerContext: -> @base.base
