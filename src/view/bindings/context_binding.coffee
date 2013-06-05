#= require ./abstract_attribute_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: true

  bindingName: 'context'

  constructor: ->
    super

    contextAttribute = if @attributeName
      "data-#{@bindingName}-#{@attributeName}"
    else
      "data-#{@bindingName}"

    @node.removeAttribute(contextAttribute)
    @node.insertBefore(document.createComment("batman-#{contextAttribute}=\"#{@keyPath}\""), @node.firstChild)

  dataChange: (proxiedObject) ->
    @backingView.set(@attributeName || 'proxiedObject', proxiedObject)
