
BindingDefinitionOnlyObserve = require './binding_definition_only_observe'

# `Batman.DOM.attrReaders` contains all the DOM directives which take an argument in their name, in the
# `data-dosomething-argument="keypath"` style. This means things like foreach, binding attributes like
# disabled or anything arbitrary, descending into a context, binding specific classes, or binding to events.
module.exports = attrReaders =
  _parseAttribute: (value) ->
    if value is 'false' then value = false
    if value is 'true' then value = true
    value

  source: (definition) ->
    definition.onlyObserve = BindingDefinitionOnlyObserve.Data
    attrReaders.bind(definition)

  bind: (definition) ->
    bindingClass = switch definition.attr
      when 'checked', 'disabled', 'selected'
        Batman.DOM.CheckedBinding
      when 'value', 'href', 'src', 'size'
        Batman.DOM.NodeAttributeBinding
      when 'class'
        Batman.DOM.ClassBinding
      when 'style'
        Batman.DOM.StyleBinding
      else
        Batman.DOM.AttributeBinding

    new bindingClass(definition)

  context: (definition) ->
    new Batman.DOM.ContextBinding(definition)

  event: (definition) ->
    new Batman.DOM.EventBinding(definition)

  track: (definition) ->
    if definition.attr == 'view'
      new Batman.DOM.ViewTrackingBinding(definition)
    else if definition.attr == 'click'
      new Batman.DOM.ClickTrackingBinding(definition)

  addclass: (definition) ->
    new Batman.DOM.AddClassBinding(definition)

  removeclass: (definition) ->
    definition.invert = true
    new Batman.DOM.AddClassBinding(definition)

  foreach: (definition) ->
    new Batman.DOM.IteratorBinding(definition)

  formfor: (definition) ->
    new Batman.DOM.FormBinding(definition)

  style: (definition) ->
    new Batman.DOM.StyleAttributeBinding(definition)
