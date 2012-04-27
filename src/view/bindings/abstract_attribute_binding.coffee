#= require abstract_binding

class Batman.DOM.AbstractAttributeBinding extends Batman.DOM.AbstractBinding
  constructor: (node, @attributeName, args...) -> super(node, args...)
