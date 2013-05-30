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

  subviews: []
  superview: null
  controller: null

  source: null
  html: null
  node: null

  isBound: false
  isInDOM: false
  isView: true

  constructor: ->
    @subviews = new Batman.Set

    @subviews.on 'itemsWereAdded', (newSubviews) =>
      @_addSubview(subview) for subview in newSubviews
      return

    @subviews.on 'itemsWereRemoved', (oldSubviews) =>
      subview._removeFromSuperview() for subview in oldSubviews
      return

    super

  _addSubview: (subview) ->
    subview.removeFromSuperview()

    subview.set('superview', this)
    subview.fire('viewDidMoveToSuperview')

    @prevent('childViewsReady')
    subview.once('ready', @_fireChildViewsReady ||= => @allowAndFire('childViewsReady'))

    subview.initializeBindings()

    if yieldName = subview.contentFor
      yieldObject = Batman.DOM.Yield.withName(subview.contentFor)
      yieldObject.set('contentView', subview)

    else
      parentNode = subview.parentNode
      parentNode = Batman.DOM.querySelector(@get('node'), parentNode) if typeof parentNode is 'string'
      parentNode = @node if not parentNode

      subview.addToParentNode(parentNode)

  _removeFromSuperview: ->
    @fire('viewWillRemoveFromSuperview')

    superview = @get('superview')
    @off('ready', superview._fireChildViewsReady)

    destroy = true # FIXME
    @removeFromParentNode(destroy)
    @destroyBindings() if detroy

    @set('superview', null)

  removeFromSuperview: ->
    @superview?.subviews.remove(this)

  addToParentNode: (parentNode) ->
    isInDOM = document.body.contains(parentNode)
    @propagateToSubviews('viewWillAppear') if isInDOM

    parentNode.appendChild(node) if node = @get('node')

    @propagateToSubviews('isInDOM', isInDOM)
    @propagateToSubviews('viewDidAppear') if isInDOM

  removeFromParentNode: (destroy) ->
    node = @get('node')
    isInDOM = document.body.contains(node)

    @propagateToSubviews('viewWillDisappear') if isInDOM

    if destroy
      Batman.DOM.destroyNode(@node)
    else
      @node.parentNode?.removeChild(@node)

    @propagateToSubviews('isInDOM', false)
    @propagateToSubviews('viewDidDisappear')

  propagateToSubviews: (eventName, value) ->
    if value?
      @set(eventName, value)
    else
      @fire(eventName)
      @[eventName]?()

    subview.propagateToSubviews(eventName, value) for subview in @subviews._storage

  loadView: ->
    if (html = @get('html'))?
      node = document.createElement('div')
      Batman.DOM.setInnerHTML(node, html)
      return node

  @accessor 'html',
    get: ->
      return @html if @html?
      return unless source = @get('source')

      source = Batman.Navigator.normalizePath(source)
      @html = @constructor.store.get(source)

    set: Batman.Property.defaultAccessor.set

  @accessor 'node',
    get: ->
      if not @node
        node = @loadView()
        @set('node', node) if node
        @fire('viewDidLoad')

      return @node

    set: (key, node) ->
      @node = node
      return if not node

      Batman._data(node, 'view', this)
      Batman.developer.do =>
        extraInfo = @get('displayName') || @get('source')
        (if node == document then document.body else node).setAttribute?('data-batman-view', @constructor.name + if extraInfo then ": #{extraInfo}" else '')

      return node

  initializeBindings: ->
    return if @isBound
    new Batman.Renderer(@node, this)

    @set('isBound', true)
    @fire('ready')

  destroyBindings: ->

  baseForKeypath: (keypath) ->
    keypath.split('.')[0].split('|')[0].trim()

  targetForKeypathBase: (base) ->
    proxiedObject = @proxiedObject
    lookupNode = proxiedObject || this

    while lookupNode
      if Batman.get(lookupNode, base)?
        return lookupNode

      controller = lookupNode.controller if lookupNode.isView and lookupNode.controller

      if proxiedObject and lookupNode == proxiedObject
        lookupNode = this
      else if lookupNode.isView and lookupNode.superview
        lookupNode = lookupNode.superview
      else if controller
        lookupNode = controller
        controller = null
      else if lookupNode != Batman.currentApp
        lookupNode = Batman.currentApp
      else
        lookupNode = null

  lookupKeypath: (keypath) ->
    base = @baseForKeypath(keypath)
    target = @targetForKeypathBase(base)

    Batman.get(target, keypath) if target

  die: ->
    @fire('destroy', @node)
    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()
    @subview.forEach (name, subview) -> subview.die()
    @_removeFromSuperview() if @superview

Batman.container.$context ?= (node) ->
  while node
    return view if view = (Batman._data(node, 'backingView') || Batman._data(node, 'view'))
    node = node.parentNode

Batman.container.$subviews ?= (view = Batman.currentApp.layout) ->
  subviews = {}

  view.subviews.forEach (key, subview) ->
    obj = Batman.mixin({}, subview)
    obj.constructor = subview.constructor
    obj.subviews = if subview.subviews?.length then $subviews(subview) else null
    Batman.unmixin(obj, {'_batman': true})

    subviews[key.toString()] = obj

  subviews
