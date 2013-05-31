#= require ./abstract_binding
#= require ../view

class Batman.DeferredRenderView extends Batman.View
  bindImmediately: false

class Batman.DOM.DeferredRenderBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: Batman.DeferredRenderView
  skipChildren: true

  dataChange: (value) ->
    if value and not @backingView.isBound
      @node.removeAttribute('data-renderif')
      @backingView.initializeBindings()

