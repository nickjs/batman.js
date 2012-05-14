#= require ./abstract_attribute_binding

class Batman.DOM.NodeAttributeBinding extends Batman.DOM.AbstractAttributeBinding
  dataChange: (value = "") -> @node[@attributeName] = value
  nodeChange: (node) ->
    if @isTwoWay()
      @set 'filteredValue', Batman.DOM.attrReaders._parseAttribute(node[@attributeName])
