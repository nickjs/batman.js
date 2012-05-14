#= require ./abstract_binding

class Batman.DOM.MixinBinding extends Batman.DOM.AbstractBinding
  dataChange: (value) -> Batman.mixin @node, value if value?
