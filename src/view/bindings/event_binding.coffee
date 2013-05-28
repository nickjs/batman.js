#= require ./abstract_attribute_binding

class Batman.DOM.EventBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: ->
    super

    callback = =>
      target = @view.targetForKeypathBase(@key)
      @get('filteredValue')?.apply(target, arguments)

    if attacher = Batman.DOM.events[@attributeName]
      attacher(@node, callback, @view)
    else
      Batman.DOM.events.other(@node, @attributeName, callback, @view)

  _unfilteredValue: (key) ->
    if not @functionName and (index = key.lastIndexOf('.')) != -1
      @functionPath = key.substr(0, index)
      @functionName = key.substr(index + 1)

    value = super(@functionPath || key)
    if @functionName
      value?[@functionName]
    else
      value