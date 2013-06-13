#= require ./abstract_attribute_binding

class Batman.DOM.EventBinding extends Batman.DOM.AbstractAttributeBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
  bindImmediately: false

  constructor: ->
    super

    callback = =>
      func = @get('filteredValue')
      target = @view.targetForKeypathBase(@functionPath || @unfilteredKey)
      if target && @functionPath
        target = Batman.get(target, @functionPath)

      return func?.apply(target, arguments)

    if attacher = Batman.DOM.events[@attributeName]
      attacher(@node, callback, @view)
    else
      Batman.DOM.events.other(@node, @attributeName, callback, @view)

    @view.bindings.push(this)

  _unfilteredValue: (key) ->
    @unfilteredKey = key
    if not @functionName and (index = key.lastIndexOf('.')) != -1
      @functionPath = key.substr(0, index)
      @functionName = key.substr(index + 1)

    value = super(@functionPath || key)
    if @functionName
      value?[@functionName]
    else
      value
