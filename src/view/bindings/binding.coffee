#= require ./abstract_binding

class Batman.DOM.Binding extends Batman.DOM.AbstractBinding
  constructor: (node) ->
    @isInputBinding = node.nodeName.toLowerCase() in ['input', 'textarea']
    super

  nodeChange: (node, context) ->
    if @isTwoWay()
      @set 'filteredValue', @node.value

  dataChange: (value, node) ->
    Batman.DOM.valueForNode @node, value, @escapeValue
