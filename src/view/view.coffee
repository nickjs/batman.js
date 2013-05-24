class Batman.View extends Batman.Object
  subviews: {}
  superview: null
  controller: null

  constructor: ->
    @subviews = new Batman.Hash
    @_yieldNodes = {}

    @subviews.on 'itemsWereAdded', (subviewNames...) =>
      for name in subviewNames
        subview = @subviews.get(name)
        @_addSubview(subview, name)
      return

    @subviews.on 'itemsWereRemoved', (subviewNames...) =>
      for name in subviewNames
        subview = @subviews.get(name)
        subview._removeFromSuperview()
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

      @initializeBindings()
      node

  initializeBindings: ->
    new Batman.Renderer(@node, Batman.RenderContext.root(), this)

    yieldNodes = @node.querySelectorAll('[data-yield]')
    for node in yieldNodes
      name = node.getAttribute('data-yield')
      @_yieldNodes[name] = node

    return

    # viewNodes = @node.querySelectorAll('[data-view]')
    # viewNodes.forEach (viewNode) ->
    #   identifier = Math.floor(Math.rand()*10) #FIXMEEEEEE
    #   commentNode = document.createCommentNode("yield-#{identifier}")
    #   viewNode.parentNode.replaceChild(commentNode, viewNode)

    #   viewClass = Batman.View.findByClassName(viewNode.getAttribute('data-view'))
    #   view = new viewClass
    #   @addSubview(view, identifier)

  lookupKeypath: (keypath) ->

  firstAncestorWithYieldNamed: (yieldName) ->
    return this if yieldName of @_yieldNodes
    while superview = @superview
      return superview if yieldName of superview._yieldNodes
