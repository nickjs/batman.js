Yield = require './yield'
BindingDefinitionOnlyObserve = require './binding_definition_only_observe'
attrReaders = require './attribute_readers'
# TODO:
# - view, navigator, bindings

# `Batman.DOM.readers` contains the functions used for binding a node's value or innerHTML, showing/hiding nodes,
# and any other `data-#{name}=""` style DOM directives.
module.exports = readers =
  target: (definition) ->
    definition.onlyObserve = BindingDefinitionOnlyObserve.Node
    readers.bind(definition)

  source: (definition) ->
    definition.onlyObserve = BindingDefinitionOnlyObserve.Data
    readers.bind(definition)

  bind: (definition) ->
    {node} = definition
    switch node.nodeName.toLowerCase()
      when 'input'
        switch node.getAttribute('type')
          when 'checkbox'
            definition.attr = 'checked'
            attrReaders.bind(definition)
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

  deferif: (definition) ->
    definition.invert = true
    new Batman.DOM.DeferredRenderBinding(definition)

  renderif: (definition) ->
    new Batman.DOM.DeferredRenderBinding(definition)

  route: (definition) ->
    new Batman.DOM.RouteBinding(definition)

  view: (definition) ->
    new Batman.DOM.ViewBinding(definition)

  partial: (definition) ->
    {node, keyPath, view} = definition

    node.removeAttribute('data-partial')
    partialView = new Batman.View(source: keyPath, parentNode: node, node: node)

    skipChildren: true
    initialized: ->
      partialView.loadView(node)
      view.subviews.add(partialView)

  defineview: (definition) ->
    {node, view, keyPath} = definition

    Batman.View.store.set(Batman.Navigator.normalizePath(keyPath), node.innerHTML)

    skipChildren: true
    initialized: ->
      if node.parentNode
        node.parentNode.removeChild(node)

  contentfor: (definition) ->
    {node, keyPath, view} = definition

    contentView = new Batman.View(html: node.innerHTML, contentFor: keyPath)
    contentView.addToParentNode = (parentNode) ->
      parentNode.innerHTML = ''
      parentNode.appendChild(@get('node'))

    view.subviews.add(contentView)

    skipChildren: true
    initialized: ->
      if node.parentNode
        node.parentNode.removeChild(node)

  yield: (definition) ->
    yieldObject = Yield.withName(definition.keyPath)
    yieldObject.set('containerNode', definition.node)

    skipChildren: true

  debug: (definition) ->
    new Batman.Dom.DebuggerBinding(definition)
