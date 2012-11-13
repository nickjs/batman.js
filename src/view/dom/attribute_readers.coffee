#= require ./dom

# `Batman.DOM.attrReaders` contains all the DOM directives which take an argument in their name, in the
# `data-dosomething-argument="keypath"` style. This means things like foreach, binding attributes like
# disabled or anything arbitrary, descending into a context, binding specific classes, or binding to events.
Batman.DOM.attrReaders =
  _parseAttribute: (value) ->
    if value is 'false' then value = false
    if value is 'true' then value = true
    value

  source: (node, attr, key, context, renderer) ->
    Batman.DOM.attrReaders.bind node, attr, key, context, renderer, 'dataChange'

  bind: (node, attr, key, context, renderer, only) ->
    bindingClass = switch attr
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
    new bindingClass(node, attr, key, context, renderer, only)
    true

  context: (node, contextName, key, context) -> return context.descendWithKey(key, contextName)

  event: (node, eventName, key, context) ->
    new Batman.DOM.EventBinding(node, eventName, key, context)
    true

  addclass: (node, className, key, context, parentRenderer, invert) ->
    new Batman.DOM.AddClassBinding(node, className, key, context, parentRenderer, false, invert)
    true

  removeclass: (node, className, key, context, parentRenderer) -> Batman.DOM.attrReaders.addclass node, className, key, context, parentRenderer, yes

  foreach: (node, iteratorName, key, context, parentRenderer) ->
    new Batman.DOM.IteratorBinding(node, iteratorName, key, context, parentRenderer)
    false # Return false so the Renderer doesn't descend into this node's children.

  formfor: (node, localName, key, context) ->
    new Batman.DOM.FormBinding(node, localName, key, context)
    context.descendWithKey(key, localName)
