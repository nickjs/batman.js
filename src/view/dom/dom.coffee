#= require_tree ../../event_emitter
#= require_tree ../../observable

# Some helpers which are defined in the platform adapters:
#
# querySelector
# querySelectorAll
# appendChild
# removeNode
# destroyNode
# setInnerHTML
# textContent

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
      Batman.DOM.setInnerHTML container, ''
      Batman.DOM.appendChild container, view.get('node')
      renderer.allowAndFire 'rendered'

  propagateBindingEvent: (binding, node) ->
    while (current = (current || node).parentNode)
      parentBindings = Batman._data current, 'bindings'
      if parentBindings?
        for parentBinding in parentBindings
          parentBinding.childBindingAdded?(binding)
    return

  propagateBindingEvents: (newNode) ->
    Batman.DOM.propagateBindingEvents(child) for child in newNode.childNodes
    if bindings = Batman._data newNode, 'bindings'
      for binding in bindings
        Batman.DOM.propagateBindingEvent(binding, newNode)
    return

  # Adds a binding or binding-like object to the `bindings` set in a node's
  # data, so that upon node removal we can unset the binding and any other objects
  # it retains. Also notify any parent bindings of the appearance of new bindings underneath
  trackBinding: (binding, node) ->
    if bindings = Batman._data node, 'bindings'
      bindings.push(binding)
    else
      Batman._data node, 'bindings', [binding]

    Batman.DOM.fire('bindingAdded', binding)
    Batman.DOM.propagateBindingEvent(binding, node)
    true

  onParseExit: (node, callback) ->
    set = Batman._data(node, 'onParseExit') || Batman._data(node, 'onParseExit', new Batman.SimpleSet)
    set.add callback if callback?
    set

  forgetParseExit: (node, callback) -> Batman.removeData(node, 'onParseExit', true)

  defineView: (name, node) ->
    contents = node.innerHTML
    Batman.View.store.set(Batman.Navigator.normalizePath(name), contents)
    contents

  setStyleProperty: (node, property, value, importance) ->
    if node.style.setProperty
      node.style.setProperty(property, value, importance)
    else
      node.style.setAttribute(property, value, importance)

  removeOrDestroyNode: (node) ->
    view = Batman._data(node, 'view')
    view ||= Batman._data(node, 'yielder')
    if view? && view.get('cached')
      Batman.DOM.removeNode(node)
    else
      Batman.DOM.destroyNode(node)

  insertBefore: (parentNode, newNode, referenceNode = null) ->
    if !referenceNode or parentNode.childNodes.length <= 0
      Batman.DOM.appendChild parentNode, newNode
    else
      Batman.DOM.willInsertNode(newNode)
      parentNode.insertBefore newNode, referenceNode
      Batman.DOM.didInsertNode(newNode)

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

  hasAddEventListener: !!window?.addEventListener

  preventDefault: (e) ->
    if typeof e.preventDefault is "function" then e.preventDefault() else e.returnValue = false

  stopPropagation: (e) ->
    if e.stopPropagation then e.stopPropagation() else e.cancelBubble = true

  willInsertNode: (node) ->
    view = Batman._data node, 'view'
    view?.fire 'beforeAppear', node
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
      view.die()

    # break down all bindings
    if bindings = Batman._data node, 'bindings'
      bindings.forEach (binding) -> binding.die()

    # remove all event listeners
    if listeners = Batman._data node, 'listeners'
      for eventName, eventListeners of listeners
        eventListeners.forEach (listener) ->
          Batman.DOM.removeEventListener node, eventName, listener

    # remove all bindings and other data associated with this node
    Batman.removeData node, null, null, true  # internal and external data (Batman._data and Batman.data)

    Batman.DOM.didDestroyNode(child) for child in node.childNodes
    true

Batman.mixin Batman.DOM, Batman.EventEmitter, Batman.Observable
Batman.DOM.event('bindingAdded')
