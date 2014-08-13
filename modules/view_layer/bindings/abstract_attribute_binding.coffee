AbstractBinding = require './abstract_binding'

module.exports = class AbstractAttributeBinding extends AbstractBinding
  constructor: (definition) ->
    @attributeName = definition.attr
    super
