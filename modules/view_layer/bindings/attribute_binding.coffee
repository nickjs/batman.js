AbstractAttributeBinding = require './abstract_attribute_binding'
attrReaders = require '../dom/attribute_readers'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'

module.exports = class AttributeBinding extends AbstractAttributeBinding
  onlyObserve: BindingDefinitionOnlyObserve.Data

  dataChange: (value) -> @node.setAttribute(@attributeName, value)
  nodeChange: (node) ->
    if @isTwoWay()
      @set 'filteredValue', attrReaders._parseAttribute(node.getAttribute(@attributeName))
