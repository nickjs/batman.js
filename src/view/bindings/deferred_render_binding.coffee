#= require ../view
#= require ./abstract_binding

class Batman.DOM.DeferredRenderBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  skipChildren: true

  rendered: false

  constructor: (definition) ->
    {node, keyPath, view: @superview} = definition
    return {} if Batman._data(node, 'view') instanceof Batman.DeferredRenderView

    @yieldName = "<renderif-#{@_batmanID()}-#{keyPath}>"
    @renderView = new Batman.DeferredRenderView()
    @superview.declareYieldNode(@yieldName, node)

    super

  dataChange: (value) ->
    if value and not @renderView.superview
      @renderView.set('node', @node)
      @superview.subviews.set(@yieldName, @renderView)

class Batman.DeferredRenderView extends Batman.View
  addToDOM: ->