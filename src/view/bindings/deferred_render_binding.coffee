#= require ./abstract_binding

class Batman.DOM.DeferredRenderBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: true

  rendered: false

  constructor: (definition) ->
    @renderNode = definition.node
    definition.node = null
    super

  dataChange: (value) ->
    if value and not @rendered
      @renderNode.removeAttribute('data-renderif')

      @rendered = true
      @backingView.set('node', @renderNode)
      @backingView.initializeBindings()
