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

    if options = @view.constructor._batman.get('options')
      for option in options when keyPath = @node.getAttribute("data-view-#{option.toLowerCase()}")
        definition = new Batman.DOM.ReaderBindingDefinition(@node, keyPath, @superview)
        new Batman.DOM.ViewArgumentBinding(definition, option, @view)

    @yieldName ||= "<#{@view.constructor.name || 'UnknownView'}-#{@_batmanID()}>"
    @superview.declareYieldNode(@yieldName, @node)
    @superview.subviews.set(@yieldName, @view)

  die: ->
    @superview.unset(@yieldName)
    @superview = null
    @view = null
    super

class Batman.DOM.ViewArgumentBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition, @option, @targetView) ->
    super(definition)

  dataChange: (value) ->
    @targetView.set(@option, value)
