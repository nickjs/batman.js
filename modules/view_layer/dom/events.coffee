DOM = require './dom'

# `Batman.DOM.events` contains the Batman.helpers used for binding to events. These aren't called by
# DOM directives, but are used to handle specific events by the `data-event-#{name}` helper.
module.exports = events =
  primaryInteractionEvent: (node, callback, view, eventName = DOM.primaryInteractionEventName, preventDefault = true) ->
    DOM.addEventListener node, eventName, (event, args...) ->
      return if event.metaKey || event.ctrlKey || event.button == 1

      DOM.preventDefault event if preventDefault
      return if not DOM.eventIsAllowed(eventName, event)

      callback node, event, args..., view

    if node.nodeName.toUpperCase() is 'A' and not node.href
      node.href = '#'

    node

  click: (node, callback, view, eventName = 'click', preventDefault = true) ->
    events.primaryInteractionEvent node, callback, view, eventName, preventDefault

  doubleclick: (node, callback, view) ->
    # The actual DOM event is called `dblclick`
    events.click node, callback, view, 'dblclick'

  change: (node, callback, view) ->
    eventNames = switch node.nodeName.toUpperCase()
      when 'TEXTAREA' then ['input', 'keyup', 'change']
      when 'INPUT'
        if node.type.toLowerCase() in DOM.textInputTypes
          oldCallback = callback
          callback = (node, event, view) ->
            return if event.type is 'keyup' and events.isEnter(event)
            oldCallback(node, event, view)
          ['input', 'keyup', 'change']
        else
          ['input', 'change']
      else ['change']

    for eventName in eventNames
      DOM.addEventListener node, eventName, (args...) ->
        callback node, args..., view
    return

  isEnter: (ev) ->
    (13 <= ev.keyCode <= 14) || (13 <= ev.which <= 14) || ev.keyIdentifier is 'Enter' || ev.key is 'Enter'

  submit: (node, callback, view) ->
    if DOM.nodeIsEditable(node)
      DOM.addEventListener node, 'keydown', (args...) ->
        if events.isEnter(args[0])
          DOM._keyCapturingNode = node

      DOM.addEventListener node, 'keyup', (args...) ->
        if events.isEnter(args[0])
          if DOM._keyCapturingNode is node
            DOM.preventDefault args[0]
            callback(node, args..., view)

          DOM._keyCapturingNode = null
    else
      DOM.addEventListener node, 'submit', (args...) ->
        DOM.preventDefault(args[0])
        callback(node, args..., view)
    node

  other: (node, eventName, callback, view) ->
    DOM.addEventListener(node, eventName, (args...) -> callback node, args..., view)


