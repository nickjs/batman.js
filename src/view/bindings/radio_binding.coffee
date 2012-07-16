#= require ./abstract_binding

class Batman.DOM.RadioBinding extends Batman.DOM.AbstractBinding
  constructor: (node) ->
    super
    @set 'filteredValue', node.value if node.checked

  dataChange: (value) ->
    boundValue = @get 'filteredValue'
    @node.checked = (boundValue is Batman.DOM.attrReaders._parseAttribute(@node.value)) if boundValue?

  nodeChange: (node) ->
    if @isTwoWay()
      @set 'filteredValue', Batman.DOM.attrReaders._parseAttribute(node.value)
