#= require ./dom

class Batman.DOM.ReaderBindingDefinition
  constructor: (@node, @keyPath, @view, @renderer) ->

Batman.BindingDefinitionOnlyObserve =
  Data: 'data'
  Node: 'node'
  All: 'all'
  None: 'none'

# `Batman.DOM.readers` contains the functions used for binding a node's value or innerHTML, showing/hiding nodes,
# and any other `data-#{name}=""` style DOM directives.
Batman.DOM.readers =
  target: (definition) ->
    definition.onlyObserve = Batman.BindingDefinitionOnlyObserve.Node
    Batman.DOM.readers.bind(definition)

  source: (definition) ->
    definition.onlyObserve = Batman.BindingDefinitionOnlyObserve.Data
    Batman.DOM.readers.bind(definition)

  bind: (definition) ->
    {node} = definition
    switch node.nodeName.toLowerCase()
      when 'input'
        switch node.getAttribute('type')
          when 'checkbox'
            definition.attr = 'checked'
            Batman.DOM.attrReaders.bind(definition)
            return true
          when 'radio'
            bindingClass = Batman.DOM.RadioBinding
          when 'file'
            bindingClass = Batman.DOM.FileBinding
      when 'select'
        bindingClass = Batman.DOM.SelectBinding

    bindingClass ||= Batman.DOM.ValueBinding
    new bindingClass(definition)

  context: (definition) ->
    new Batman.DOM.ContextBinding(definition)

  showif: (definition) ->
    new Batman.DOM.ShowHideBinding(definition)

  hideif: (definition) ->
    definition.invert = true
    new Batman.DOM.ShowHideBinding(definition)

  insertif: (definition) ->
    new Batman.DOM.InsertionBinding(definition)

  removeif: (definition) ->
    definition.invert = true
    new Batman.DOM.InsertionBinding(definition)

  route: (definition) ->
    new Batman.DOM.RouteBinding(definition)

  view: (definition) ->
    new Batman.DOM.ViewBinding(definition)

  partial: (definition) ->
    Batman.DOM.partial(definition.node, definition.keyPath, definition.view)

  defineview: (definition) ->
    {node, view, keyPath} = definition

    Batman.DOM.defineView(keyPath, node)

    view.on 'ready', -> #FIXME when parseNode goes away this doesn't need to nextTick
      node.parentNode.removeChild(node)

    {skipChildren: true}

  renderif: (definition) ->
    new Batman.DOM.DeferredRenderingBinding(definition)


  contentfor: (definition) ->
    {node, swapMethod, keyPath, view} = definition
    swapMethod ||= 'append'

    contentView = new Batman.View
    contentView.get('node').innerHTML = node.innerHTML

    parentView = view.firstAncestorWithYieldNamed(keyPath)
    parentView.subviews.set(keyPath, contentView)

    view.on 'ready', -> # FIXME when parseNode goes away this doesn't need to nextTick
      node.parentNode.removeChild(node)

    {skipChildren: true}


  replace: (definition) ->
    definition.swapMethod = 'replace'
    Batman.DOM.readers.contentfor(definition)
