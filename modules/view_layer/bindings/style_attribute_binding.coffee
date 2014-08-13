NodeAttributeBinding = require './node_attribute_binding'

module.exports = class StyleAttributeBinding extends NodeAttributeBinding
  dataChange: (value) ->
    @node.style[Batman.Filters.camelize(@attributeName, true)] = value
