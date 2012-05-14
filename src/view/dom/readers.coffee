#= require ./dom

# `Batman.DOM.readers` contains the functions used for binding a node's value or innerHTML, showing/hiding nodes,
# and any other `data-#{name}=""` style DOM directives.
Batman.DOM.readers =
  target: (node, key, context, renderer) ->
    Batman.DOM.readers.bind(node, key, context, renderer, 'nodeChange')
    true

  source: (node, key, context, renderer) ->
    Batman.DOM.readers.bind(node, key, context, renderer, 'dataChange')
    true

  bind: (node, key, context, renderer, only) ->
    bindingClass = false
    switch node.nodeName.toLowerCase()
      when 'input'
        switch node.getAttribute('type')
          when 'checkbox'
            Batman.DOM.attrReaders.bind(node, 'checked', key, context, renderer, only)
            return true
          when 'radio'
            bindingClass = Batman.DOM.RadioBinding
          when 'file'
            bindingClass = Batman.DOM.FileBinding
      when 'select'
        bindingClass = Batman.DOM.SelectBinding
    bindingClass ||= Batman.DOM.Binding
    new bindingClass(arguments...)
    true

  context: (node, key, context, renderer) -> return context.descendWithKey(key)

  mixin: (node, key, context, renderer) ->
    new Batman.DOM.MixinBinding(node, key, context.descend(Batman.mixins), renderer)
    true

  showif: (node, key, context, parentRenderer, invert) ->
    new Batman.DOM.ShowHideBinding(node, key, context, parentRenderer, false, invert)
    true

  hideif: -> Batman.DOM.readers.showif(arguments..., yes)

  route: ->
    new Batman.DOM.RouteBinding(arguments...)
    true

  view: ->
    new Batman.DOM.ViewBinding arguments...
    false

  partial: (node, path, context, renderer) ->
    Batman.DOM.partial node, path, context, renderer
    true

  defineview: (node, name, context, renderer) ->
    Batman.onParseExit(node, -> Batman.destroyNode(node))
    Batman.View.store.set(Batman.Navigator.normalizePath(name), node.innerHTML)
    false

  renderif: (node, key, context, renderer) ->
    new Batman.DOM.DeferredRenderingBinding(node, key, context, renderer)
    false

  yield: (node, key) ->
    Batman.onParseExit node, -> Batman.DOM.Yield.withName(key).set 'containerNode', node
    true
  contentfor: (node, key, context, renderer, action = 'append') ->
    Batman.onParseExit node, ->
      node.parentNode?.removeChild(node)
      renderer.view.pushYieldAction(key, action, node)
    true
  replace: (node, key, context, renderer) ->
    Batman.DOM.readers.contentfor(node, key, context, renderer, 'replace')
    true
