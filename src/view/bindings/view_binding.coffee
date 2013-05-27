#= require ./abstract_binding

class Batman.DOM.ViewBinding extends Batman.DOM.AbstractBinding
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    @superview = definition.view
    super


  dataChange: (viewClassOrInstance) ->
    return unless viewClassOrInstance?
    if viewClassOrInstance.isView
      @view = viewClassOrInstance
    else
      @view = new viewClassOrInstance

    @yieldName = "<#{@view.constructor.name || 'UnknownView'}-#{@view._batmanID()}>"
    @superview.declareYieldNode(@yieldName, @node)
    @superview.subviews.set(@yieldName, @view)

  die: ->
    @superview.unset(@yieldName)
    @superview = null
    @view = null
    super
