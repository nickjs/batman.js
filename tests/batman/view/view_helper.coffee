$ = window.$ unless $
if ! IN_NODE
  exports = window.viewHelpers = {}
else
  global.$ = $
  exports = module.exports

exports.triggerChange = (domNode) ->
  if document.createEvent
    evt = document.createEvent("HTMLEvents")
    evt.initEvent("change", true, true)
    domNode.dispatchEvent(evt)
  else if document.createEventObject
    domNode.fireEvent 'onchange'

exports.triggerFocus = (domNode) ->
  if document.createEvent
    evt = document.createEvent("HTMLEvents")
    evt.initEvent("focus", false, false)
    domNode.dispatchEvent(evt)
  else if document.createEventObject
    domNode.fireEvent 'onfocus'

exports.triggerClick = (domNode, eventName = 'click', options = {}) ->
  options = Batman.extend {ctrlKey: false, altKey: false, shiftKey: false, metaKey: false, button: 0}, options
  if document.createEvent
    evt = document.createEvent("MouseEvents")
    evt.initMouseEvent(eventName, true, true, window, 0, 0, 0, 0, 0, options.ctrlKey, options.altKey, options.shiftKey, options.metaKey, options.button, null)
    domNode.dispatchEvent(evt)
  else if document.createEventObject
    domNode.fireEvent 'on'+eventName

exports.triggerDoubleClick = (domNode) ->
  exports.triggerClick domNode, 'dblclick'

exports.triggerMiddleClick = (domNode) ->
  exports.triggerClick domNode, 'click', {button: 1}

keyIdentifiers =
  13: 'Enter'

window.getKeyEvent = _getKeyEvent = (eventName, keyCode) ->
  if document.createEvent
    evt = document.createEvent "KeyboardEvent"

    if evt.initKeyEvent
      evt.initKeyEvent(eventName, true, true, window, 0, 0, 0, 0, keyCode, keyCode)
    else if evt.initKeyboardEvent
      evt.initKeyboardEvent(eventName, true, true, window, keyIdentifiers[keyCode], keyIdentifiers[keyCode], false, false, keyCode, keyCode)
    else
      # JSDOM doesn't yet implement KeyboardEvents...  We'll simulate them instead.
      evt._type = eventName
      evt._bubbles = true
      evt._cancelable = true
      evt._target = window
      evt._currentTarget = null
      evt._keyIdentifier = keyIdentifiers[keyCode]
      evt._keyLocation = keyIdentifiers[keyCode]
      evt.which = evt.keyCode = keyCode

  else if document.createEventObject
    # IE 8 land
    evt = document.createEventObject("KeyboardEvent")
    evt.type = eventName
    evt.cancelBubble = false
    evt.keyCode = keyCode

  evt

exports.triggerKey = (domNode, keyCode, eventNames = ["keydown", "keypress", "keyup"]) ->
  for eventName in eventNames
    event = _getKeyEvent(eventName, keyCode)
    if document.createEvent
      domNode.dispatchEvent event
    else if document.createEventObject
      domNode.fireEvent 'on'+eventName, event

exports.triggerSubmit = (domNode) ->
  if document.createEvent
    evt = document.createEvent('HTMLEvents')
    evt.initEvent('submit', true, true)
    domNode.dispatchEvent(evt)
  else if document.createEventObject
    domNode.fireEvent 'onsubmit'

exports.withNodeInDom = (node, callback) ->
  node = $(node)
  $('body').append(node)
  do callback
  node.remove()

exports.splitAndSortedEquals = (a, b, split = ',') ->
  deepEqual a.split(split).sort(), b.split(split).sort()

# Helper function for rendering a view given a context. Optionally returns a jQuery of the nodes,
# and calls a callback with the same. Beware of the 50ms timeout when rendering views, tests should
# be async and rely on the view.ready one shot event for running assertions.
outstandingNodes = []

exports.render = (html, jqueryize = true, context = {}, callback = ->) ->
  unless !!jqueryize == jqueryize
    [context, callback] = [jqueryize, context]
  else
    if typeof context == 'function'
      callback = context

  context.html = html
  view = new Batman.View(context)

  view.on 'ready', ->
    Batman.setImmediate ->
      outstandingNodes.push(view.get('node'))
      node = if jqueryize then $(view.get('node')).children() else view.get('node')
      callback(node, view)

  view.get('node')
  view.propagateToSubviews('viewWillAppear')
  view.initializeBindings()
  view.propagateToSubviews('isInDOM', true)
  view.propagateToSubviews('viewDidAppear')

# Destroy outstanding nodes
QUnit.testDone ->
  Batman.DOM.destroyNode(node) for node in outstandingNodes
  outstandingNodes = []
