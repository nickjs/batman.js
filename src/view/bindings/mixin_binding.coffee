#= require ./abstract_binding

class Batman.DOM.MixinBinding extends Batman.DOM.AbstractBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  dataChange: (value) -> Batman.mixin @node, value if value?
