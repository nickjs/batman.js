#= require ./abstract_binding
#= require ../view

class Batman.DeferredRenderView extends Batman.View
  bindImmediately: false

class Batman.DOM.DeferredRenderBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: Batman.DeferredRenderView
  skipChildren: true

  constructor: (definition) ->
    {@invert} = definition
    @attributeName = if @invert then 'data-delayif' else 'data-renderif'
    super

  dataChange: (value) ->
    if !!value is !@invert and not @backingView.isBound
      @node.removeAttribute(@attributeName)
      @backingView.initializeBindings()
