class Batman.DOM.CssBinding extends Batman.DOM.NodeAttributeBinding
  dataChange: (value) ->
    @node.style[@attributeName] = value
