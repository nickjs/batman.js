#= require ./abstract_attribute_binding

class Batman.DOM.EventBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: ->
    super

    callback = =>
      target = @view.targetForKeypathBase(@view.baseForKeypath(@keyPath))
      @get('filteredValue')?.apply(target, arguments)

    if attacher = Batman.DOM.events[@attributeName]
      attacher(@node, callback, @view)
    else
      Batman.DOM.events.other(@node, @attributeName, callback, @view)
