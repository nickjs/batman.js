AbstractAttributeBinding = require './abstract_attribute_binding'
BindingDefinitionOnlyObserve = require '../dom/binding_definition_only_observe'
View = require '../view'

{developer, get} = require 'foundation'

module.exports = class EventBinding extends AbstractAttributeBinding
  onlyObserve: BindingDefinitionOnlyObserve.None
  bindImmediately: false

  constructor: ->
    super
    developer.do =>
      if @key in View.LIFECYCLE_EVENTS
        developer.error("Event handler named '#{@key}' conflicts with a View lifecycle event of the same name! Rename the handler on <#{@node.nodeName.toLowerCase()} data-event-#{@attributeName}='#{@keyPath}' />.")

    callback = =>
      func = @get('filteredValue')
      target = @view.targetForKeypath(@functionPath || @unfilteredKey)
      if target && @functionPath
        target = get(target, @functionPath)

      return func?.apply(target, arguments)

    if attacher = Batman.DOM.events[@attributeName]
      attacher(@node, callback, @view)
    else
      Batman.DOM.events.other(@node, @attributeName, callback, @view)

    @bind()

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
