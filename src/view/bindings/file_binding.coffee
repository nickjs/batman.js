#= require ./abstract_binding

class Batman.DOM.FileBinding extends Batman.DOM.AbstractBinding
  isInputBinding: true
  nodeChange: (node, subContext) ->
    return if !@isTwoWay()
    if node.hasAttribute('multiple')
      @set 'filteredValue', Array::slice.call(node.files)
    else
      @set 'filteredValue', node.files[0]
