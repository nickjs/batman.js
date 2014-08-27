NodeAttributeBinding = require './node_attribute_binding'

module.exports = class CheckedBinding extends NodeAttributeBinding
  isInputBinding: true
  dataChange: (value) ->
    @node[@attributeName] = !!value
