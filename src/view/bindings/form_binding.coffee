#= require ./context_binding

class Batman.DOM.FormBinding extends Batman.DOM.ContextBinding
  @current: null
  errorClass: 'error'
  defaultErrorsListSelector: 'div.errors'

  @accessor 'errorsListSelector', ->
    @get('node').getAttribute('data-errors-list') || @defaultErrorsListSelector

  constructor: (definition) ->
    {@node, attr: @proxyName, keyPath} = definition
    return {} if Batman._data(@node, 'view') instanceof Batman.ProxyView

    Batman.DOM.events.submit(@node, (node, e) -> Batman.DOM.preventDefault(e))
    @setupErrorsList()

    selectors = ['input', 'textarea'].map (nodeName) => nodeName + "[data-bind^=\"#{keyPath}\"]"
    selectedNodes = Batman.DOM.querySelectorAll(@node, selectors.join(', '))

    for selectedNode in selectedNodes
      binding = selectedNode.getAttribute('data-bind')
      field = binding.slice(binding.indexOf(@proxyName) + @proxyName.length + 1)

      selectedNode.setAttribute("data-addclass-#{@errorClass}", "#{@proxyName}.errors.#{field}.length")

    super

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
