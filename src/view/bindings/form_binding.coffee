#= require ./context_binding

class Batman.DOM.FormBinding extends Batman.DOM.ContextBinding
  bindingName: 'formfor'

  errorClass: 'error'
  defaultErrorsListSelector: 'div.errors'

  constructor: (definition) ->
    super

    @initializeErrorsList()
    @initializeChildBindings()
    Batman.DOM.events.submit(@node, (node, e) -> Batman.DOM.preventDefault(e))

  initializeChildBindings: ->
    keyPath = @keyPath
    attribute = @attributeName

    selectors = ['input', 'textarea', 'select'].map (nodeName) -> "#{nodeName}[data-bind^=\"#{attribute}\"]"
    selectedNodes = Batman.DOM.querySelectorAll(@node, selectors.join(', '))

    for selectedNode in selectedNodes
      binding = selectedNode.getAttribute('data-bind')
      field = binding.substr(binding.indexOf(attribute) + attribute.length + 1)

      index = field.indexOf('|')
      field = field.substr(0, index) if index != -1

      field = field.trim()

      selectedNode.setAttribute("data-addclass-#{@errorClass}", "#{attribute}.errors.#{field}.length")

    errorsNode = Batman.DOM.querySelector(@node, '.errors')
    errorsNode.setAttribute('data-showif', "#{attribute}.errors.length") if errorsNode and !errorsNode.getAttribute('data-showif')

    return

  initializeErrorsList: ->
    selector = @node.getAttribute('data-errors-list') || @defaultErrorsListSelector
    Batman.DOM.setInnerHTML(errorsNode, @errorsListHTML()) if errorsNode = Batman.DOM.querySelector(@node, selector)

  errorsListHTML: ->
    """
    <ul>
      <li data-foreach-error="#{@attributeName}.errors" data-bind="error.fullMessage"></li>
    </ul>
    """
