#= require_tree ../../event_emitter
#= require_tree ../../observable

# Some helpers which are defined in the platform adapters:
#
# querySelector
# querySelectorAll
#
Batman.DOM =
  # List of input type="types" for which we can use keyup events to track
  textInputTypes: ['text', 'search', 'tel', 'url', 'email', 'password']

  scrollIntoView: (elementID) ->
    document.getElementById(elementID)?.scrollIntoView?()

  partial: (container, path, context, renderer) ->
    renderer.prevent 'rendered'

    view = new Batman.View
      source: path
      context: context

    view.on 'ready', ->
      Batman.setInnerHTML container, ''
      Batman.appendChild container, view.get('node')
      renderer.allowAndFire 'rendered'

  propagateBindingEvent: Batman.propagateBindingEvent = (binding, node) ->
    while (current = (current || node).parentNode)
      parentBindings = Batman._data current, 'bindings'
      if parentBindings?
        for parentBinding in parentBindings
          parentBinding.childBindingAdded?(binding)
    return

  propagateBindingEvents: Batman.propagateBindingEvents = (newNode) ->
    Batman.propagateBindingEvents(child) for child in newNode.childNodes
    if bindings = Batman._data newNode, 'bindings'
      for binding in bindings
        Batman.propagateBindingEvent(binding, newNode)
    return

  # Adds a binding or binding-like object to the `bindings` set in a node's
  # data, so that upon node removal we can unset the binding and any other objects
  # it retains. Also notify any parent bindings of the appearance of new bindings underneath
  trackBinding: Batman.trackBinding = (binding, node) ->
    if bindings = Batman._data node, 'bindings'
      bindings.push(binding)
    else
      Batman._data node, 'bindings', [binding]

    Batman.DOM.fire('bindingAdded', binding)
    Batman.propagateBindingEvent(binding, node)
    true

  onParseExit: Batman.onParseExit = (node, callback) ->
    set = Batman._data(node, 'onParseExit') || Batman._data(node, 'onParseExit', new Batman.SimpleSet)
    set.add callback if callback?
    set

  forgetParseExit: Batman.forgetParseExit = (node, callback) -> Batman.removeData(node, 'onParseExit', true)

  defineView: (name, node) ->
    contents = node.innerHTML
    Batman.View.store.set(Batman.Navigator.normalizePath(name), contents)
    contents

  setStyleProperty: Batman.setStyleProperty = (node, property, value, importance) ->
    if node.style.setAttribute
      node.style.setAttribute(property, value, importance)
    else
      node.style.setProperty(property, value, importance)

  destroyNode: Batman.destroyNode = (node) ->
    Batman.DOM.willDestroyNode(node)
    Batman.removeNode(node)
    Batman.DOM.didDestroyNode(node)

  removeOrDestroyNode: Batman.removeOrDestroyNode = (node) ->
    view = Batman._data(node, 'view')
    view ||= Batman._data(node, 'yielder')
    if view? && view.get('cached')
      Batman.DOM.removeNode(node)
    else
      Batman.DOM.destroyNode(node)

  insertBefore: Batman.insertBefore = (parentNode, newNode, referenceNode = null) ->
    if !referenceNode or parentNode.childNodes.length <= 0
      Batman.appendChild parentNode, newNode
    else
      Batman.DOM.willInsertNode(newNode)
      parentNode.insertBefore newNode, referenceNode
      Batman.DOM.didInsertNode(newNode)

  valueForNode: (node, value = '', escapeValue = true) ->
    isSetting = arguments.length > 1
    switch node.nodeName.toUpperCase()
      when 'INPUT', 'TEXTAREA'
        if isSetting then (node.value = value) else node.value
      when 'SELECT'
        if isSetting then node.value = value
      else
        if isSetting
          Batman.setInnerHTML node, if escapeValue then Batman.escapeHTML(value) else value
        else node.innerHTML

  nodeIsEditable: (node) ->
    node.nodeName.toUpperCase() in ['INPUT', 'TEXTAREA', 'SELECT']

  # `Batman.addEventListener uses attachEvent when necessary
  addEventListener: Batman.addEventListener = (node, eventName, callback) ->
    # store the listener in Batman.data
    unless listeners = Batman._data node, 'listeners'
      listeners = Batman._data node, 'listeners', {}
    unless listeners[eventName]
      listeners[eventName] = []
    listeners[eventName].push callback

    if Batman.hasAddEventListener
      node.addEventListener eventName, callback, false
    else
      node.attachEvent "on#{eventName}", callback

  # `Batman.removeEventListener` uses detachEvent when necessary
  removeEventListener: Batman.removeEventListener = (node, eventName, callback) ->
    # remove the listener from Batman.data
    if listeners = Batman._data node, 'listeners'
      if eventListeners = listeners[eventName]
        index = eventListeners.indexOf(callback)
        if index != -1
          eventListeners.splice(index, 1)

    if Batman.hasAddEventListener
      node.removeEventListener eventName, callback, false
    else
      node.detachEvent 'on'+eventName, callback

  hasAddEventListener: Batman.hasAddEventListener = !!window?.addEventListener

  # `Batman.preventDefault` checks for preventDefault, since it's not
  # always available across all browsers
  preventDefault: Batman.preventDefault = (e) ->
    if typeof e.preventDefault is "function" then e.preventDefault() else e.returnValue = false

  stopPropagation: Batman.stopPropagation = (e) ->
    if e.stopPropagation then e.stopPropagation() else e.cancelBubble = true

  willInsertNode: (node) ->
    view = Batman._data node, 'view'
    view?.fire 'beforeAppear', node
    Batman.data(node, 'show')?.call(node)
    Batman.DOM.willInsertNode(child) for child in node.childNodes
    true

  didInsertNode: (node) ->
    view = Batman._data node, 'view'
    if view
      view.fire 'appear', node
      view.applyYields()
    Batman.DOM.didInsertNode(child) for child in node.childNodes
    true

  willRemoveNode: (node) ->
    view = Batman._data node, 'view'
    if view
      view.fire 'beforeDisappear', node
    Batman.data(node, 'hide')?.call(node)
    Batman.DOM.willRemoveNode(child) for child in node.childNodes
    true

  didRemoveNode: (node) ->
    view = Batman._data node, 'view'
    if view
      view.retractYields()
      view.fire 'disappear', node
    Batman.DOM.didRemoveNode(child) for child in node.childNodes
    true

  willDestroyNode: (node) ->
    view = Batman._data node, 'view'
    if view
      view.fire 'beforeDestroy', node
      view.get('yields').forEach (name, actions) ->
        for {node} in actions
          Batman.DOM.willDestroyNode(node)
    Batman.DOM.willDestroyNode(child) for child in node.childNodes
    true

  didDestroyNode: (node) ->
    view = Batman._data node, 'view'
    if view
      view.fire 'destroy', node
      view.get('yields').forEach (name, actions) ->
        for {node} in actions
          Batman.DOM.didDestroyNode(node)

    # break down all bindings
    if bindings = Batman._data node, 'bindings'
      bindings.forEach (binding) -> binding.die()

    # remove all event listeners
    if listeners = Batman._data node, 'listeners'
      for eventName, eventListeners of listeners
        eventListeners.forEach (listener) ->
          Batman.removeEventListener node, eventName, listener

    # remove all bindings and other data associated with this node
    Batman.removeData node                   # external data (Batman.data)
    Batman.removeData node, undefined, true  # internal data (Batman._data)

    Batman.DOM.didDestroyNode(child) for child in node.childNodes
    true

Batman.mixin Batman.DOM, Batman.EventEmitter, Batman.Observable
Batman.DOM.event('bindingAdded')
