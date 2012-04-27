#= require ../object
#= require view_store

# A `Batman.View` can function two ways: a mechanism to load and/or parse html files
# or a root of a subclass hierarchy to create rich UI classes, like in Cocoa.
class Batman.View extends Batman.Object
  @store: new Batman.ViewStore()
  @option: (keys...) ->
    keys.forEach (key) =>
      @accessor @::_argumentBindingKey(key), (bindingKey) ->
        return unless (node = @get 'node') && (context = @get 'context')
        keyPath = node.getAttribute "data-view-#{key}".toLowerCase()
        return unless keyPath?
        @[bindingKey]?.die()
        @[bindingKey] = new Batman.DOM.ViewArgumentBinding node, keyPath, context

    @accessor keys..., (key) ->
      @get(@_argumentBindingKey(key))?.get('filteredValue')

  isView: true
  _rendered: false
  # Set the source attribute to an html file to have that file loaded.
  source: ''
  # Set the html to a string of html to have that html parsed.
  html: ''
  # Set an existing DOM node to parse immediately.
  node: null

  # Fires once a node is parsed.
  @::event('ready').oneShot = true

  @accessor 'html',
    get: ->
      return @html if @html && @html.length > 0
      return unless source = @get 'source'
      source = Batman.Navigator.normalizePath(source)
      @html = @constructor.store.get(source)
    set: (_, html) -> @html = html

  @accessor 'node'
    get: ->
      unless @node
        html = @get('html')
        return unless html && html.length > 0
        @node = document.createElement 'div'
        @_setNodeOwner(@node)
        Batman.setInnerHTML(@node, html)
      return @node
    set: (_, node) ->
      @node = node
      @_setNodeOwner(node)
      updateHTML = (html) =>
        if html?
          Batman.setInnerHTML(@get('node'), html)
          @forget('html', updateHTML)
      @observeAndFire 'html', updateHTML

  class @YieldStorage extends Batman.Hash
    @wrapAccessor (core) ->
      get: (key) ->
        val = core.get.call(@, key)
        if !val?
          val = @set key, []
        val

  @accessor 'yields', -> new @constructor.YieldStorage

  constructor: (options = {}) ->
    context = options.context
    if context
      unless context instanceof Batman.RenderContext
        context = Batman.RenderContext.root().descend(context)
    else
      context = Batman.RenderContext.root()
    options.context = context.descend(@)
    super(options)

    # Start the rendering by asking for the node
    Batman.Property.withoutTracking =>
      if node = @get('node')
        @render node
      else
        @observe 'node', (node) => @render(node)

  render: (node) ->
    return if @_rendered
    @_rendered = true
    @event('ready').resetOneShot()

    # We use a renderer with the continuation style rendering engine to not
    # block user interaction for too long during the render.
    if node
      @_renderer = new Batman.Renderer(node, null, @context, @)
      @_renderer.on 'rendered', =>
        @fire('ready', node)

  isInDOM: ->
    if (node = @get('node'))
      node.parentNode? ||
        @get('yields').some (name, nodes) ->
          for {node} in nodes
            return true if node.parentNode?
          return false
    else
      false

  applyYields: ->
    @get('yields').forEach (name, nodes) ->
      yieldObject = Batman.DOM.Yield.withName(name)
      for {node, action} in nodes
        yieldObject[action](node)

  retractYields: ->
    @get('yields').forEach (name, nodes) ->
      node.parentNode?.removeChild(node) for {node} in nodes

  pushYieldAction: (key, action, node) ->
    @_setNodeYielder(node)
    @get("yields").get(key).push({node, action})

  _argumentBindingKey: (key) -> "_#{key}ArgumentBinding"
  _setNodeOwner: (node) -> Batman._data(node, 'view', @)
  _setNodeYielder: (node) -> Batman._data(node, 'yielder', @)

  @::on 'ready', -> @ready? arguments...
  @::on 'appear', -> @viewDidAppear? arguments...
  @::on 'disappear', -> @viewDidDisappear? arguments...
  @::on 'beforeAppear', -> @viewWillAppear? arguments...
  @::on 'beforeDisappear', -> @viewWillDisappear? arguments...
