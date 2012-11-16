#= require ./abstract_attribute_binding

class Batman.DOM.AttributeBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  dataChange: (value) -> @node.setAttribute(@attributeName, value)
  nodeChange: (node) ->
    if @isTwoWay()
      @set 'filteredValue', Batman.DOM.attrReaders._parseAttribute(node.getAttribute(@attributeName))
