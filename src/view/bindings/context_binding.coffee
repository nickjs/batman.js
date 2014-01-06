#= require ./abstract_attribute_binding

class Batman.DOM.ContextBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  backWithView: true

  bindingName: 'context'

  constructor: (definition) ->
    @contextKeypath = definition.attr || 'proxiedObject'

    super

    contextAttribute = if @attributeName
      "data-#{@bindingName}-#{@attributeName}"
    else
      "data-#{@bindingName}"

    @node.removeAttribute(contextAttribute)
    @node.insertBefore(document.createComment("batman-#{contextAttribute}=\"#{@keyPath}\""), @node.firstChild)

    @backingView.observe @contextKeypath, @_updateValue = (value) =>
      return if @isDataChanging
      @view.setKeypath(@keyPath, value)

  dataChange: (proxiedObject) ->
    @isDataChanging = true
    @backingView.set(@contextKeypath, proxiedObject)
    @isDataChanging = false

  die: ->
    @backingView.forget(@contextKeypath, @_updateValue)
    @backingView.unset(@contextKeypath)
    super
