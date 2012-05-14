#= require ./dom

# `Batman.DOM.events` contains the Batman.helpers used for binding to events. These aren't called by
# DOM directives, but are used to handle specific events by the `data-event-#{name}` helper.
Batman.DOM.events =
  click: (node, callback, context, eventName = 'click') ->
    Batman.addEventListener node, eventName, (args...) ->
      callback node, args..., context
      Batman.preventDefault args[0]

    if node.nodeName.toUpperCase() is 'A' and not node.href
      node.href = '#'

    node

  doubleclick: (node, callback, context) ->
    # The actual DOM event is called `dblclick`
    Batman.DOM.events.click node, callback, context, 'dblclick'

  change: (node, callback, context) ->
    eventNames = switch node.nodeName.toUpperCase()
      when 'TEXTAREA' then ['keyup', 'change']
      when 'INPUT'
        if node.type.toLowerCase() in Batman.DOM.textInputTypes
          oldCallback = callback
          callback = (e) ->
            return if e.type == 'keyup' && 13 <= e.keyCode <= 14
            oldCallback(arguments...)
          ['keyup', 'change']
        else
          ['change']
      else ['change']

    for eventName in eventNames
      Batman.addEventListener node, eventName, (args...) ->
        callback node, args..., context

  isEnter: (ev) -> ev.keyCode is 13 || ev.which is 13 || ev.keyIdentifier is 'Enter' || ev.key is 'Enter'

  submit: (node, callback, context) ->
    if Batman.DOM.nodeIsEditable(node)
      Batman.addEventListener node, 'keydown', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          Batman.DOM._keyCapturingNode = node
      Batman.addEventListener node, 'keyup', (args...) ->
        if Batman.DOM.events.isEnter(args[0])
          if Batman.DOM._keyCapturingNode is node
            Batman.preventDefault args[0]
            callback node, args..., context
          Batman.DOM._keyCapturingNode = null
    else
      Batman.addEventListener node, 'submit', (args...) ->
        Batman.preventDefault args[0]
        callback node, args..., context

    node

  other: (node, eventName, callback, context) -> Batman.addEventListener node, eventName, (args...) -> callback node, args..., context
