Event = require '../event_emitter/event'

module.exports = class PropertyEvent extends Event
  eachHandler: (iterator) -> @eachObserver(iterator)
  handlerContext: -> @base
