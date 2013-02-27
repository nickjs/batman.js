#= require ../object
#= require ./html_store

# A `Batman.View` can function two ways: a mechanism to load and/or parse html files
# or a root of a subclass hierarchy to create rich UI classes, like in Cocoa.
class Batman.View extends Batman.Object

  class @YieldStorage extends Batman.Hash
    @wrapAccessor (core) ->
      get: (key) ->
        val = core.get.call(@, key)
        if !val?
          val = @set key, []
        val

  @store: new Batman.HTMLStore()
  @option: (keys...) ->
    @accessor keys...,
      get: (key) ->        @get("argumentBindings.#{key}")?.get('filteredValue')
      set: (key, value) -> @get("argumentBindings.#{key}")?.set('filteredValue', value)
      unset: (key) ->      @get("argumentBindings.#{key}")?.unset('filteredValue')

  isView: true
  cache: true
  _rendered: false
  # Set an existing DOM node to parse immediately.
  node: null

  # Fires once a node is parsed.
  @::event('ready').oneShot = true

  @accessor 'argumentBindings', ->
    new Batman.TerminalAccessible (key) =>
      return unless (node = @get 'node') && (context = @get 'context')
      keyPath = node.getAttribute "data-view-#{key}".toLowerCase()
      return unless keyPath?
      bindingKey = "_argumentBinding#{key}"
      @[bindingKey]?.die()

      definition = new Batman.DOM.ReaderBindingDefinition(node, keyPath, context)
      @[bindingKey] = new Batman.DOM.ViewArgumentBinding(definition)

  @accessor 'html',
    get: ->
      return @html if @html && @html.length > 0
      return unless source = @get 'source'
      source = Batman.Navigator.normalizePath(source)
      @html = @constructor.store.get(source)
    set: (_, html) -> @html = html

  @accessor 'node'
    get: ->
      unless @node?
        html = @get('html')
        return unless html && html.length > 0
        @node = document.createElement 'div'
        @_setNodeOwner(@node)
        Batman.DOM.setInnerHTML(@node, html)
      return @node
    set: (_, node) ->
      @node = node
      @_setNodeOwner(node)
      updateHTML = (html) =>
        if html?
          Batman.DOM.setInnerHTML(@node, html)
          @forget('html', updateHTML)
      @observeAndFire 'html', updateHTML
      node

  @accessor 'yields', -> new @constructor.YieldStorage
  @accessor 'fetched?', -> @get('source')?
  @accessor 'readyToRender', ->
    @get('node') && (if @get('fetched?') then @get('html')?.length > 0 else true)

  constructor: (options = {}) ->
    context = options.context
    if context
      unless context instanceof Batman.RenderContext
        context = Batman.RenderContext.root().descend(context)
    else
      context = Batman.RenderContext.root()
    options.context = context.descend(@)
    super(options)

    Batman.Property.withoutTracking =>
      @observeAndFire 'readyToRender', (ready) =>
        @render() if ready

  render: ->
    return if @_rendered
    @_rendered = true
    @_renderer = new Batman.Renderer(node = @get('node'), @get('context'), @)
    @_renderer.once 'rendered', => @fire('ready', node)

  isInDOM: ->
    if (node = @get('node'))
      node.parentNode? ||
        @get('yields').some (name, nodes) ->
          for {node} in nodes
            return true if node.parentNode?
          return false
    else
      false

  die: ->
    @fire 'destroy', @node
    @forget()
    @_batman.properties?.forEach (key, property) -> property.die()
    @get('yields').forEach (name, actions) ->
      for {node} in actions
        Batman.DOM.didDestroyNode(node)

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

  _setNodeOwner: (node) -> Batman._data(node, 'view', @)
  _setNodeYielder: (node) -> Batman._data(node, 'yielder', @)

  @::on 'ready', -> @ready? arguments...
  @::on 'appear', -> @viewDidAppear? arguments...
  @::on 'disappear', -> @viewDidDisappear? arguments...
  @::on 'beforeAppear', -> @viewWillAppear? arguments...
  @::on 'beforeDisappear', -> @viewWillDisappear? arguments...
