#= require ./dom

class Batman.DOM.ReaderBindingDefinition
  constructor: (@node, @keyPath, @context, @renderer) ->

# `Batman.DOM.readers` contains the functions used for binding a node's value or innerHTML, showing/hiding nodes,
# and any other `data-#{name}=""` style DOM directives.
Batman.DOM.readers =
  target: (definition) ->
    definition.observes = 'node'
    Batman.DOM.readers.bind(definition)

  source: (definition) ->
    definition.observes = 'data'
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
    definition.context.descendWithKey(definition.keyPath)

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

  yield: (definition) ->
    {node, keyPath} = definition
    Batman.DOM.onParseExit(node, -> Batman.DOM.Yield.withName(keyPath).set('containerNode', node))

  contentfor: (definition) ->
    {node, value, swapMethod, renderer, keyPath} = definition
    swapMethod ||= 'append'

    Batman.DOM.onParseExit node, ->
      node.parentNode?.removeChild(node)
      renderer.view.pushYieldAction(keyPath, swapMethod, node)

  replace: (definition) ->
    definition.swapMethod = 'replace'
    Batman.DOM.readers.contentfor(definition)
