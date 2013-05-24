#= require ../object

# `Batman.Renderer` will take a node and parse all recognized data attributes out of it and its children.
# It is a continuation style parser, designed not to block for longer than 50ms at a time if the document
# fragment is particularly long.
class Batman.Renderer extends Batman.Object
  deferEvery: 50
  constructor: (@node, @context, @view) ->
    super()
    Batman.developer.error "Must pass a RenderContext to a renderer for rendering" unless @context instanceof Batman.RenderContext
    @immediate = Batman.setImmediate @start

  start: =>
    @startTime = new Date
    @prevent 'parsed'
    @prevent 'rendered'
    @parseTree @node

  resume: =>
    @startTime = new Date
    @parseTree @resumeNode

  finish: ->
    @startTime = null
    @prevent 'stopped'
    @allowAndFire 'parsed'
    @allowAndFire 'rendered'

  stop: ->
    Batman.clearImmediate @immediate
    @fire 'stopped'

  for k in ['parsed', 'rendered', 'stopped']
    @::event(k).oneShot = true

  bindingSortOrder = ["view", "renderif", "foreach", "formfor", "context", "bind", "source", "target"]

  bindingSortPositions = {}
  bindingSortPositions[name] = pos for name, pos in bindingSortOrder

  _sortBindings: (a,b) ->
    aindex = bindingSortPositions[a[0]]
    bindex = bindingSortPositions[b[0]]
    aindex ?= bindingSortOrder.length # put unspecified bindings last
    bindex ?= bindingSortOrder.length
    if aindex > bindex
      1
    else if bindex > aindex
      -1
    else if a[0] > b[0]
      1
    else if b[0] > a[0]
      -1
    else
      0

  parseTree: (root) ->
    while root
      if @deferEvery && (new Date - @startTime) > @deferEvery
        @resumeNode = root
        @timeout = Batman.setImmediate @resume
        return

      skipChildren = @parseNode(root)
      root = @nextNode(root, skipChildren)

    @finish()

  parseNode: (node) ->
    skipChildren = false
    if node.getAttribute and node.attributes
      bindings = []
      for attribute in node.attributes
        continue unless attribute.nodeName?.substr(0, 5) is "data-"
        name = attribute.nodeName.substr(5)

        attrIndex = name.indexOf('-')
        bindings.push if attrIndex isnt -1
          [name.substr(0, attrIndex), name.substr(attrIndex + 1), attribute.value]
        else
          [name, undefined, attribute.value]

      for [name, attr, value] in bindings.sort(@_sortBindings)
        binding = if attr
          if reader = Batman.DOM.attrReaders[name]
            bindingDefinition = new Batman.DOM.AttrReaderBindingDefinition(node, attr, value, @context, this)
            reader(bindingDefinition)
        else
          if reader = Batman.DOM.readers[name]
            bindingDefinition = new Batman.DOM.ReaderBindingDefinition(node, value, @context, this)
            reader(bindingDefinition)

        if binding instanceof Batman.RenderContext
          oldContext = @context
          @context = binding
          Batman.DOM.onParseExit(node, => @context = oldContext)
        else if binding?.skipChildren
          skipChildren = true
          break
    return skipChildren

  nextNode: (node, skipChildren) ->
    if not skipChildren
      children = node.childNodes
      return children[0] if children?.length

    sibling = node.nextSibling # Grab the reference before onParseExit may remove the node
    Batman.DOM.onParseExit(node)?.forEach (callback) -> callback()
    Batman.DOM.forgetParseExit(node)
    return if @node == node
    return sibling if sibling

    nextParent = node
    while nextParent = nextParent.parentNode
      parentSibling = nextParent.nextSibling
      Batman.DOM.onParseExit(nextParent)?.forEach (callback) -> callback()
      Batman.DOM.forgetParseExit(nextParent)
      return if @node == nextParent
      return parentSibling if parentSibling

    return
