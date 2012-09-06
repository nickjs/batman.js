#= require ./dom

# `Batman.DOM.events` contains the Batman.helpers used for binding to events. These aren't called by
# DOM directives, but are used to handle specific events by the `data-event-#{name}` helper.
Batman.DOM.events =
  click: (node, callback, context, eventName = 'click') ->
    Batman.DOM.addEventListener node, eventName, (event, args...) ->
      return if event.metaKey || event.ctrlKey
      callback node, event, args..., context
      Batman.DOM.preventDefault event

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
            oldCallback(arguments...)
          ['input', 'keyup', 'change']
        else
          ['input', 'change']
      else ['change']

    for eventName in eventNames
      Batman.DOM.addEventListener node, eventName, (args...) ->
        callback node, args..., context

  isEnter: (ev) -> (13 <= ev.keyCode <= 14) || (13 <= ev.which <= 14) || ev.keyIdentifier is 'Enter' || ev.key is 'Enter'

  submit: (node, callback, context) ->
    if Batman.DOM.nodeIsEditable(node)
      Batman.DOM.addEventListener node, 'keydown', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          Batman.DOM._keyCapturingNode = node
      Batman.DOM.addEventListener node, 'keyup', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          if Batman.DOM._keyCapturingNode is node
            Batman.DOM.preventDefault args[0]
            callback node, args..., context
          Batman.DOM._keyCapturingNode = null
    else
      Batman.DOM.addEventListener node, 'submit', (args...) ->
        Batman.DOM.preventDefault args[0]
        callback node, args..., context

    node

  other: (node, eventName, callback, context) -> Batman.DOM.addEventListener node, eventName, (args...) -> callback node, args..., context
