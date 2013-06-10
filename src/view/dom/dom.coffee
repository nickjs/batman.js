#= require_tree ../../event_emitter
#= require_tree ../../observable

# Some helpers which are defined in the platform adapters:
#
# querySelector
# querySelectorAll
# appendChild
# destroyNode
# setInnerHTML
# textContent

Batman.DOM =
  # List of input type="types" for which we can use keyup events to track
  textInputTypes: ['text', 'search', 'tel', 'url', 'email', 'password']

  scrollIntoView: (elementID) ->
    document.getElementById(elementID)?.scrollIntoView?()

  setStyleProperty: (node, property, value, importance) ->
    if node.style.setProperty
      node.style.setProperty(property, value, importance)
    else
      node.style.setAttribute(property, value, importance)

  valueForNode: (node, value = '', escapeValue = true) ->
    isSetting = arguments.length > 1
    nodeName = node.nodeName.toUpperCase()
    switch nodeName
      when 'INPUT', 'TEXTAREA'
        if isSetting then node.value = value else node.value
      when 'SELECT'
        if isSetting then node.value = value
        else if node.multiple
          child.value for child in node.children when child.selected
        else
          node.value
      else
        if isSetting
          # IE, in its infinite wisdom, requires option nodes to update the text property instead
          # of innerHTML. We do this for all browsers since it's cheap and actually is in the spec.
          node.text = value if nodeName is 'OPTION'
          Batman.DOM.setInnerHTML node, if escapeValue then Batman.escapeHTML(value) else value
        else node.innerHTML

  nodeIsEditable: (node) ->
    node.nodeName.toUpperCase() in ['INPUT', 'TEXTAREA', 'SELECT']

  addEventListener: (node, eventName, callback) ->
    # store the listener in Batman.data
    unless listeners = Batman._data node, 'listeners'
      listeners = Batman._data node, 'listeners', {}
    unless listeners[eventName]
      listeners[eventName] = []
    listeners[eventName].push callback

    if Batman.DOM.hasAddEventListener
      node.addEventListener eventName, callback, false
    else
      node.attachEvent "on#{eventName}", callback

  removeEventListener: (node, eventName, callback) ->
    # remove the listener from Batman.data
    if listeners = Batman._data node, 'listeners'
      if eventListeners = listeners[eventName]
        index = eventListeners.indexOf(callback)
        if index != -1
          eventListeners.splice(index, 1)

    if Batman.DOM.hasAddEventListener
      node.removeEventListener eventName, callback, false
    else
      node.detachEvent 'on'+eventName, callback

  cleanupNode: (node) ->
    if listeners = Batman._data(node, 'listeners')
      for eventName, eventListeners of listeners
        eventListeners.forEach (listener) ->
          Batman.DOM.removeEventListener(node, eventName, listener)

    Batman.removeData node, null, null, true
    Batman.DOM.cleanupNode(child) for child in node.childNodes

    return

  hasAddEventListener: !!window?.addEventListener

  preventDefault: (e) ->
    if typeof e.preventDefault is "function" then e.preventDefault() else e.returnValue = false

  stopPropagation: (e) ->
    if e.stopPropagation then e.stopPropagation() else e.cancelBubble = true
