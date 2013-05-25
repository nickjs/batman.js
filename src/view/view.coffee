class Batman.View extends Batman.Object

  @option: (keys...) ->
    @accessor keys...,
      get: (key) ->        @get("argumentBindings.#{key}")?.get('filteredValue')
      set: (key, value) -> @get("argumentBindings.#{key}")?.set('filteredValue', value)
      unset: (key) ->      @get("argumentBindings.#{key}")?.unset('filteredValue')

  @accessor 'argumentBindings', ->
    new Batman.TerminalAccessible (key) =>
      return unless node = @get('node')
      keyPath = node.getAttribute "data-view-#{key}".toLowerCase()
      return unless keyPath?
      bindingKey = "_argumentBinding#{key}"
      @[bindingKey]?.die()

      definition = new Batman.DOM.ReaderBindingDefinition(node, keyPath, this)
      @[bindingKey] = new Batman.DOM.ViewArgumentBinding(definition)

  subviews: {}
  superview: null
  controller: null

  node: null
  isView: true

  constructor: ->
    @subviews = new Batman.Hash
    @_yieldNodes = {}

    @subviews.on 'itemsWereAdded', (subviewNames, newSubviews) =>
      @_addSubview(subview, subviewNames[i]) for subview, i in newSubviews
      return

    @subviews.on 'itemsWereRemoved', (subviewNames, oldSubviews) =>
      subview._removeFromSuperview() for subview in oldSubviews
      return

    @subviews.on 'itemsWereChanged', (subviewNames, newSubviews, oldSubviews) =>
      for name, i in subviewNames
        oldSubviews[i]._removeFromSuperview()
        @_addSubview(newSubviews[i], name)
      return

    super

  _addSubview: (subview, as) ->
    if siblingViews = subview.superview?.subviews
      for key, value of siblingViews.toObject() when value == subview
        siblingViews.unset(key)
        break

    # subview.fire('viewWillAppear')
    subview.set('superview', this)

    # @on 'viewWillAppear', -> subview.fire('viewWillAppear')
    # @on 'viewDidAppear', -> subview.fire('viewDidAppear')

    # if @get('isInDOM')
      # subview.fire()

    (@_yieldNodes[as] || @get('node')).appendChild(subview.get('node'))
    # subview.fire('viewDidAppear')

  _removeFromSuperview: ->
    # @fire('viewWillDisappear')
    @get('node').parentNode?.removeChild(@node)
    @set('superview', null)
    # @fire('viewDidDisappear')

  @accessor 'node',
    get: ->
      return @node if @node

      node = document.createElement('div')
      node.innerHTML = @get('html')
      @set('node', node)

    set: (key, node) ->
      @node = node
      Batman._data(node, 'view', this)
      Batman.developer.do =>
        (if node == document then document.body else node).setAttribute('data-batman-view', @constructor.name)

      @initializeYields()
      @initializeBindings()

      return node

  initializeYields: ->
    yieldNodes = Batman.DOM.querySelectorAll(@node, '[data-yield]')
    for node in yieldNodes
      yieldName = node.getAttribute('data-yield')
      @declareYieldNode(yieldName, node)

  initializeBindings: ->
    new Batman.Renderer(@node, this)

  targetForKeypath: (keypath) ->
    base = keypath.split('.')[0].split('|')[0].trim()
    lookupNode = this

    while lookupNode
      if Batman.get(lookupNode, base)?
        return lookupNode

      controller = lookupNode.controller if lookupNode.isView && lookupNode.controller

      if lookupNode.isView and lookupNode.superview
        lookupNode = lookupNode.superview
      else if controller
        lookupNode = controller
        controller = null
      else if lookupNode != Batman.currentApp
        lookupNode = Batman.currentApp
      else
        lookupNode = null

  lookupKeypath: (keypath) ->
    target = @targetForKeypath(keypath)
    Batman.get(target, keypath) if target

  declareYieldNode: (yieldName, node) ->
    @_yieldNodes[yieldName] = node

  firstAncestorWithYieldNamed: (yieldName) ->
    superview = this
    while superview
      return superview if yieldName of superview._yieldNodes
      superview = superview.superview

Batman.container.$context = (node) ->
  while node
    return view if view = Batman._data(node, 'view')
    node = node.parentNode
