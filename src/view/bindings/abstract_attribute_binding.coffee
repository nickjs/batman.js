#= require ./abstract_binding

class Batman.DOM.AbstractAttributeBinding extends Batman.DOM.AbstractBinding
  constructor: (definition) ->
    @attributeName = definition.attr
    super
