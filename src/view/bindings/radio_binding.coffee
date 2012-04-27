#= require abstract_binding

class Batman.DOM.RadioBinding extends Batman.DOM.AbstractBinding
  isInputBinding: true
  dataChange: (value) ->
    # don't overwrite `checked` attributes in the HTML unless a bound
    # value is defined in the context. if no bound value is found, bind
    # to the key if the node is checked.
    if (boundValue = @get('filteredValue'))?
      @node.checked = boundValue == @node.value
    else if @node.checked
      @set 'filteredValue', @node.value

  nodeChange: (node) ->
    if @isTwoWay()
      @set('filteredValue', Batman.DOM.attrReaders._parseAttribute(node.value))
