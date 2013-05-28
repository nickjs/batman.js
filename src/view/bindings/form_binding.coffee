#= require ./context_binding

class Batman.DOM.FormBinding extends Batman.DOM.ContextBinding
  @current: null
  errorClass: 'error'
  defaultErrorsListSelector: 'div.errors'

  @accessor 'errorsListSelector', ->
    @get('node').getAttribute('data-errors-list') || @defaultErrorsListSelector

  constructor: (definition) ->
    return {} if Batman._data(definition.node, 'view') instanceof Batman.ProxyView
    super

    Batman.DOM.events.submit(@node, (node, e) -> Batman.DOM.preventDefault(e))
    @setupErrorsList()

    @view.once 'childViewsReady', =>
      selectors = ['input', 'textarea'].map (nodeName) => nodeName + "[data-bind^=\"#{@keyPath}\"]"
      nodes = Batman.DOM.querySelectorAll(@node, selectors.join(', '))

      for node in nodes
        binding = node.getAttribute('data-bind')
        field = binding.slice(binding.indexOf(@proxyName) + @proxyName.length + 1)

        definition = new Batman.DOM.AttrReaderBindingDefinition(node, @errorClass, @proxyName + " | get 'errors.#{field}.length'", @view)
        new Batman.DOM.AddClassBinding(definition)
      return

  setupErrorsList: ->
    if @errorsListNode = Batman.DOM.querySelector(@node, @get('errorsListSelector'))
      Batman.DOM.setInnerHTML @errorsListNode, @errorsListHTML()

      unless @errorsListNode.getAttribute 'data-showif'
        @errorsListNode.setAttribute 'data-showif', "#{@proxyName}.errors.length"

  errorsListHTML: ->
    """
    <ul>
      <li data-foreach-error="#{@proxyName}.errors" data-bind="error.fullMessage"></li>
    </ul>
    """
