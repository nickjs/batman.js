class Batman.DOM.StyleAttributeBinding extends Batman.DOM.NodeAttributeBinding
  dataChange: (value) ->
    @node.style[Batman.Filters.camelize(@attributeName, true)] = value
