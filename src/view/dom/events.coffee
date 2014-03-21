#= require ./dom

# `Batman.DOM.events` contains the Batman.helpers used for binding to events. These aren't called by
# DOM directives, but are used to handle specific events by the `data-event-#{name}` helper.
Batman.DOM.events =
  primaryInteractionEvent: (node, callback, view, eventName = Batman.DOM.primaryInteractionEventName, preventDefault = true) ->
    Batman.DOM.addEventListener node, eventName, (event, args...) ->
      return if event.metaKey || event.ctrlKey || event.button == 1

      Batman.DOM.preventDefault event if preventDefault
      return if not Batman.DOM.eventIsAllowed(eventName, event)

      callback node, event, args..., view

    if node.nodeName.toUpperCase() is 'A' and not node.href
      node.href = '#'

    node

  click: (node, callback, view, eventName = 'click', preventDefault = true) ->
    Batman.DOM.events.primaryInteractionEvent node, callback, view, eventName, preventDefault

  doubleclick: (node, callback, view) ->
    # The actual DOM event is called `dblclick`
    Batman.DOM.events.click node, callback, view, 'dblclick'

  change: (node, callback, view) ->
    eventNames = switch node.nodeName.toUpperCase()
      when 'TEXTAREA' then ['input', 'keyup', 'change']
      when 'INPUT'
        if node.type.toLowerCase() in Batman.DOM.textInputTypes
          oldCallback = callback
          callback = (node, event, view) ->
            return if event.type is 'keyup' and Batman.DOM.events.isEnter(event)
            oldCallback(node, event, view)
          ['input', 'keyup', 'change']
        else
          ['input', 'change']
      else ['change']

    for eventName in eventNames
      Batman.DOM.addEventListener node, eventName, (args...) ->
        callback node, args..., view
    return

  isEnter: (ev) ->
    (13 <= ev.keyCode <= 14) || (13 <= ev.which <= 14) || ev.keyIdentifier is 'Enter' || ev.key is 'Enter'

  submit: (node, callback, view) ->
    if Batman.DOM.nodeIsEditable(node)
      Batman.DOM.addEventListener node, 'keydown', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          Batman.DOM._keyCapturingNode = node

      Batman.DOM.addEventListener node, 'keyup', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          if Batman.DOM._keyCapturingNode is node
            Batman.DOM.preventDefault args[0]
            callback(node, args..., view)

          Batman.DOM._keyCapturingNode = null

    else
      Batman.DOM.addEventListener node, 'submit', (args...) ->
        Batman.DOM.preventDefault(args[0])
        callback(node, args..., view)

    node

  other: (node, eventName, callback, view) ->
    Batman.DOM.addEventListener(node, eventName, (args...) -> callback node, args..., view)

Batman.DOM.eventIsAllowed = (eventName, event) ->
  if delegate = Batman.currentApp?.shouldAllowEvent?[eventName]
    return false if delegate(event) is false

  return true

Batman.DOM.primaryInteractionEventName = 'click'
