#= require ../object
#= require ./html_store

class Batman.View extends Batman.Object

  @store: new Batman.HTMLStore

  @option: (keys...) ->
    Batman.initializeObject(this)
    @_batman.set('options', keys)

  @viewForNode: (node, climbTree) ->
    climbTree = true if not climbTree?
    while node
      return view if view = Batman._data(node, 'view')
      return if not climbTree
      node = node.parentNode

  bindings: []
  subviews: []
  superview: null
  controller: null

  source: null
  html: null
  node: null

  bindImmediately: true
  isBound: false

  isInDOM: false
  isView: true

  constructor: ->
    @bindings = []
    @subviews = new Batman.Set

    @subviews.on 'itemsWereAdded', (newSubviews) =>
      @_addSubview(subview) for subview in newSubviews
      return

    @subviews.on 'itemsWereRemoved', (oldSubviews) =>
      subview._removeFromSuperview() for subview in oldSubviews
      return

    super

  _addChildBinding: (binding) ->
    @bindings.push(binding)
    @fire('childBindingAdded', binding)

  _addSubview: (subview) ->
    subviewController = subview.controller
    subview.removeFromSuperview()

    subview.set('controller', subviewController || @controller)
    subview.set('superview', this)
    subview.fire('viewDidMoveToSuperview')

    if (yieldName = subview.contentFor) and not subview.parentNode
      yieldObject = Batman.DOM.Yield.withName(yieldName)
      yieldObject.set('contentView', subview)

    @observe('node', subview._nodesChanged)
    subview.observe('node', subview._nodesChanged)
    subview.observe('parentNode', subview._nodesChanged)
    subview._nodesChanged()

  _removeFromSuperview: ->
    return if not @superview
    @fire('viewWillRemoveFromSuperview')

    @forget('node', @_nodesChanged)
    @forget('parentNode', @_nodesChanged)
    @superview.forget('node', @_nodesChanged)

    superview = @get('superview')

    @removeFromParentNode()

    @set('superview', null)
    @set('controller', null)

  removeFromSuperview: ->
    @superview?.subviews.remove(this)

  _nodesChanged: ->
    return if not @node
    @initializeBindings() if @bindImmediately

    superviewNode = @superview.get('node')
    parentNode = @parentNode
    parentNode = Batman.DOM.querySelector(superviewNode, parentNode) if typeof parentNode is 'string'
    parentNode = superviewNode if not parentNode

    @addToParentNode(parentNode)

  addToParentNode: (parentNode) ->
    return if not @get('node')

    isInDOM = document.body.contains(parentNode)
    @propagateToSubviews('viewWillAppear') if isInDOM

    parentNode.appendChild(@node) if parentNode != @node

    @propagateToSubviews('isInDOM', isInDOM)
    @propagateToSubviews('viewDidAppear') if isInDOM

  removeFromParentNode: ->
    node = @get('node')
    isInDOM = document.body.contains(node)

    @propagateToSubviews('viewWillDisappear') if isInDOM

    @node?.parentNode?.removeChild(@node)

    @propagateToSubviews('isInDOM', false)
    @propagateToSubviews('viewDidDisappear') if isInDOM

  propagateToSubviews: (eventName, value) ->
    if value?
      @set(eventName, value)
    else
      @fire(eventName)
      @[eventName]?()

    subview.propagateToSubviews(eventName, value) for subview in @subviews._storage

  # You should never call load view directly. It will be automatically
  # invoked if a node is needed and does not exist, and cannot be
  # loaded in any other way. You SHOULD, however, override it in a
  # subclass, if you want to build a custom node.
  loadView: (_node) ->
    if (html = @get('html'))?
      node = _node || document.createElement('div')
      Batman.DOM.setInnerHTML(node, html)
      return node

  @accessor 'html',
    get: ->
      return @html if @html?
      return unless source = @get('source')

      source = Batman.Navigator.normalizePath(source)
      @html = @constructor.store.get(source)

    set: (key, html) ->
      @html = html
      @isBound = false

      @loadView(@node) if @node and html?
      @initializeBindings() if @bindImmediately

  @accessor 'node',
    get: ->
      if not @node?
        node = @loadView()
        @set('node', node) if node
        @fire('viewDidLoad')

      return @node

    set: (key, node, oldNode) ->
      Batman.removeData(oldNode, 'view', true) if oldNode
      return if node == @node

      @node = node
      @isBound = false
      return if not node

      Batman._data(node, 'view', this)
      Batman.developer.do =>
        extraInfo = @get('displayName') || @get('source')
        (if node == document then document.body else node).setAttribute?('batman-view', @constructor.name + if extraInfo then ": #{extraInfo}" else '')

      if @superview and @parentNode
        @initializeBindings() if @bindImmediately
        @addToParentNode(@parentNode)

      return node

  @::event('ready').oneShot = true

  initializeBindings: ->
    return if @isBound or !@node
    new Batman.Renderer(@node, this)

    @set('isBound', true)
    @fire('ready')
    @ready?()

  destroyBindings: ->

  baseForKeypath: (keypath) ->
    keypath.split('.')[0].split('|')[0].trim()

  targetForKeypathBase: (base) ->
    proxiedObject = @get('proxiedObject')
    lookupNode = proxiedObject || this

    while lookupNode
      if typeof Batman.get(lookupNode, base) isnt 'undefined'
        return lookupNode

      controller = lookupNode.controller if lookupNode.isView and lookupNode.controller

      if proxiedObject and lookupNode == proxiedObject
        lookupNode = this
      else if lookupNode.isView and lookupNode.superview
        lookupNode = lookupNode.superview
      else if controller
        lookupNode = controller
        controller = null
      else if not lookupNode.window
        if Batman.currentApp and lookupNode != Batman.currentApp
          lookupNode = Batman.currentApp
        else
          lookupNode = {window: Batman.container}
      else
        return

  lookupKeypath: (keypath) ->
    base = @baseForKeypath(keypath)
    target = @targetForKeypathBase(base)

    Batman.get(target, keypath) if target

  die: ->
    @fire('destroy')

    Batman.DOM.destroyNode(@node)
    @removeFromSuperview()

    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()

    if @_batman.events
      event.clearHandlers() for _, event of @_batman.events

    binding.die() for binding in @bindings
    subview.die() for subview in @subviews.toArray()

    @node = null

Batman.container.$context ?= (node) ->
  while node
    return view if view = (Batman._data(node, 'backingView') || Batman._data(node, 'view'))
    node = node.parentNode

Batman.container.$subviews ?= (view = Batman.currentApp.layout) ->
  subviews = []

  view.subviews.forEach (subview) ->
    obj = Batman.mixin({}, subview)
    obj.constructor = subview.constructor
    obj.subviews = if subview.subviews?.length then $subviews(subview) else null
    Batman.unmixin(obj, {'_batman': true})

    subviews.push(obj)

  subviews
