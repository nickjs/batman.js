AbstractAttributeBinding = require './abstract_attribute_binding'
attrReaders = require '../dom/attribute_readers'

module.exports = class NodeAttributeBinding extends AbstractAttributeBinding
  dataChange: (value = "") -> @node[@attributeName] = value
  nodeChange: (node) ->
    if @isTwoWay()
      @set 'filteredValue', attrReaders._parseAttribute(node[@attributeName])
