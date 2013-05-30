#= require ./abstract_binding

class Batman.DOM.ViewBinding extends Batman.DOM.AbstractBinding
  skipChildren: true
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition) ->
    @superview = definition.view
    super

  dataChange: (viewClassOrInstance) ->
    @viewInstance?.removeFromSuperview()

    return if not viewClassOrInstance
    if viewClassOrInstance.isView
      @viewInstance = viewClassOrInstance
    else
      @viewInstance = new viewClassOrInstance

    if options = @viewInstance.constructor._batman.get('options')
      for option in options when keyPath = @node.getAttribute("data-view-#{option.toLowerCase()}")
        definition = new Batman.DOM.ReaderBindingDefinition(@node, keyPath, @superview)
        new Batman.DOM.ViewArgumentBinding(definition, option, @viewInstance)

    @viewInstance.set('parentNode', @node)
    @superview.subviews.add(@viewInstance)

  die: ->
    @viewInstance.removeFromSuperview()
    @superview = null
    @viewInstance = null
    super

class Batman.DOM.ViewArgumentBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: (definition, @option, @targetView) ->
    super(definition)

  dataChange: (value) ->
    @targetView.set(@option, value)
