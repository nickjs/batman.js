#= require node_attribute_binding

class Batman.DOM.CheckedBinding extends Batman.DOM.NodeAttributeBinding
  isInputBinding: true
  dataChange: (value) ->
    @node[@attributeName] = !!value
