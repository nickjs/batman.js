AbstractBinding = require './abstract_binding'

module.exports = class ValueBinding extends AbstractBinding
  constructor: (definition) ->
    @isInputBinding = definition.node.nodeName.toLowerCase() in ['input', 'textarea']
    super

  nodeChange: (node, context) ->
    if @isTwoWay()
      @set('filteredValue', @node.value)

  dataChange: (value, node) ->
    Batman.DOM.valueForNode(@node, value, @escapeValue)
