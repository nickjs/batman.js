#= require ./abstract_binding

class Batman.DOM.ViewBinding extends Batman.DOM.AbstractBinding
  skipChildren: true
  bindImmediately: false
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    super

    @yieldName = "view-#{@hashKey()}"
    @superview = definition.view
    @superview.declareYieldNode(@yieldName, @node)

    @bind()


  dataChange: (viewClassOrInstance) ->
    return unless viewClassOrInstance?
    if viewClassOrInstance.isView
      @view = viewClassOrInstance
    else
      @view = new viewClassOrInstance

    @superview.subviews.set(@yieldName, @view)

  die: ->
    @superview.unset(@yieldName)
    @superview = null
    @view = null
    super
