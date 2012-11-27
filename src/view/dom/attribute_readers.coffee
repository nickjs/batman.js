#= require ./dom

class Batman.DOM.AttrReaderBindingDefinition
  constructor: (@node, @attr, @keyPath, @context, @renderer) ->

# `Batman.DOM.attrReaders` contains all the DOM directives which take an argument in their name, in the
# `data-dosomething-argument="keypath"` style. This means things like foreach, binding attributes like
# disabled or anything arbitrary, descending into a context, binding specific classes, or binding to events.
Batman.DOM.attrReaders =
  _parseAttribute: (value) ->
    if value is 'false' then value = false
    if value is 'true' then value = true
    value

  source: (definition) ->
    definition.onlyObserve = Batman.BindingDefinitionOnlyObserve.Data
    Batman.DOM.attrReaders.bind(definition)

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
    definition.context.descendWithDefinition(definition)

  event: (definition) ->
    new Batman.DOM.EventBinding(definition)

  addclass: (definition) ->
    new Batman.DOM.AddClassBinding(definition)

  removeclass: (definition) ->
    definition.invert = true
    new Batman.DOM.AddClassBinding(definition)

  foreach: (definition) ->
    new Batman.DOM.IteratorBinding(definition)

  formfor: (definition) ->
    new Batman.DOM.FormBinding(definition)
    definition.context.descendWithDefinition(definition)
