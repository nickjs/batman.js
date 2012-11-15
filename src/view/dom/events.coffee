#= require ./dom

# `Batman.DOM.events` contains the Batman.helpers used for binding to events. These aren't called by
# DOM directives, but are used to handle specific events by the `data-event-#{name}` helper.
Batman.DOM.events = {
  click: (node, callback, context, eventName = 'click') ->
    Batman.DOM.addEventListener node, eventName, callbackForEvent.click(callback, context)

    if node.nodeName.toUpperCase() is 'A' and not node.href
      node.href = '#'

    node

  doubleclick: (node, callback, context) ->
    # The actual DOM event is called `dblclick`
    Batman.DOM.events.click node, callback, context, 'dblclick'

  change: (node, callback, context) ->
    eventNames = switch node.nodeName.toUpperCase()
      when 'TEXTAREA' then ['input', 'keyup', 'change']
      when 'INPUT'
        if node.type.toLowerCase() in Batman.DOM.textInputTypes
          oldCallback = callback
          callback = (node, event) ->
            return if event.type is 'keyup' and Batman.DOM.events.isEnter(event)
            oldCallback(node, event)
          ['input', 'keyup', 'change']
        else
          ['input', 'change']
      else ['change']

    for eventName in eventNames
      Batman.DOM.addEventListener node, eventName, callbackForEvent.change(callback, context)

  isEnter: (ev) -> (13 <= ev.keyCode <= 14) || (13 <= ev.which <= 14) || ev.keyIdentifier is 'Enter' || ev.key is 'Enter'

  submit: (node, callback, context) ->
    if Batman.DOM.nodeIsEditable(node)
      Batman.DOM.addEventListener node, 'keydown', callbackForEvent.keyDown(callback, context)
      Batman.DOM.addEventListener node, 'keyup',   callbackForEvent.keyUp(callback, context)
    else
      Batman.DOM.addEventListener node, 'submit',  callbackForEvent.submit(callback, context)
    node

  other: (node, eventName, callback, context) ->
    Batman.DOM.addEventListener node, eventName, callbackForEvent.other(callback, context)
}

Batman.DOM.eventIsAllowed = (eventName, event) ->
  if delegate = Batman.currentApp?.shouldAllowEvent?[eventName]
    return false if delegate(event) is false

  return true

# we keep these closures separate so we don't maintain references to unwanted variables like node

callbackForEvent = {
  click: (block, context) ->
    (event) ->
      return if event.metaKey || event.ctrlKey

      Batman.DOM.preventDefault event
      return if not Batman.DOM.eventIsAllowed(event.type, event)

      block(event.target, event, context)

  change: (block, context) ->
    (event) ->
      block(event.target, event, context)

  keyDown: (block, context) ->
    (event) ->
      if Batman.DOM.events.isEnter(event)
        Batman.DOM._keyCapturingNode = event.target

  keyUp: (block, context) ->
    (event) ->
      if Batman.DOM.events.isEnter(event)
        node = event.target
        if Batman.DOM._keyCapturingNode is node
          Batman.DOM.preventDefault(event)
          block(node, event, context)
        Batman.DOM._keyCapturingNode = null

  submit: (block, context) ->
    (event) ->
      Batman.DOM.preventDefault(event)
      block(event.target, event, context)

  other: (block, context) ->
    (event) ->
      block(event.target, event, context)
}
