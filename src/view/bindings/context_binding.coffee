#= require ./abstract_attribute_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: true

  constructor: ->
    super

    contextAttribute = if @attributeName
      "data-context-#{@attributeName}"
    else
      'data-context'

    @node.removeAttribute(contextAttribute)
    @node.insertBefore(document.createComment("#{contextAttribute}=\"#{@keyPath}\""), @node.firstChild)

  dataChange: (proxiedObject) ->
    @backingView.set(@attributeName || 'proxiedObject', proxiedObject)
