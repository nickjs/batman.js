#= require ./dom

class Batman.DOM.ReaderBindingDefinition
  constructor: (@node, @keyPath, @context, @renderer, @view) ->

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
    definition.context.descendWithDefinition(definition)

  mixin: (definition) ->
    definition.context = definition.context.descend(Batman.mixins)
    new Batman.DOM.MixinBinding(definition)

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
    Batman.DOM.partial definition.node, definition.keyPath, definition.context, definition.renderer

  defineview: (definition) ->
    {node} = definition
    Batman.DOM.onParseExit(node, -> node.parentNode?.removeChild(node))
    Batman.DOM.defineView(definition.keyPath, node)
    {skipChildren: true}

  renderif: (definition) ->
    new Batman.DOM.DeferredRenderingBinding(definition)


  contentfor: (definition) ->
    {node, swapMethod, renderer, keyPath} = definition
    swapMethod ||= 'append'

    node.parentNode.removeChild(node)

    contentView = new Batman.View
    contentView.get('node').innerHTML = node.innerHTML

    parentView = definition.view.firstAncestorWithYieldNamed(keyPath)
    parentView.subviews.set(keyPath, contentView)


  replace: (definition) ->
    definition.swapMethod = 'replace'
    Batman.DOM.readers.contentfor(definition)
