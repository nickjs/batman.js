AbstractBinding = require './abstract_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'
ViewArgumentBinding = require './view_argument_binding'

module.exports = class ViewBinding extends AbstractBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data
  skipChildren: true
  bindImmediately: false

  constructor: (definition) ->
    @superview = definition.view
    super

  initialized: ->
    @bind()

  dataChange: (viewClassOrInstance) ->
    @viewInstance?.removeFromSuperview()

    return if not viewClassOrInstance
    if viewClassOrInstance.isView
      @fromViewClass = false
      @viewInstance = viewClassOrInstance
      @viewInstance.removeFromSuperview()
    else
      @fromViewClass = true
      @viewInstance = new viewClassOrInstance

    @node.removeAttribute('data-view')

    if options = @viewInstance.constructor._batman.get('options')
      for option in options
        attributeName = "data-view-#{option.toLowerCase()}"
        if keyPath = @node.getAttribute(attributeName)
          @node.removeAttribute(attributeName)
          definition = new Batman.DOM.ReaderBindingDefinition(@node, keyPath, @superview)
          new ViewArgumentBinding(definition, option, @viewInstance)

    @viewInstance.set('parentNode', @node)
    @viewInstance.set('node', @node)
    @viewInstance.loadView(@node)

    @superview.subviews.add(@viewInstance)

  die: ->
    if @fromViewClass
      @viewInstance.die()
    else
      @viewInstance.removeFromSuperview()

    @superview = null
    @viewInstance = null
    super
