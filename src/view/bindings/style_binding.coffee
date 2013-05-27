#= require ./abstract_collection_binding

class Batman.DOM.StyleBinding extends Batman.DOM.AbstractCollectionBinding
  onlyObserve: Batman.BindingDefinitionOnlyObserve.Data

  constructor: ->
    @oldStyles = {}
    @styleBindings = {}
    super

  dataChange: (value) ->
    unless value
      @resetStyles()
      return

    @unbindCollection()

    if typeof value is 'string'
      @resetStyles()
      for style in value.split(';')
        # handle a case when css value contains colons itself (absolute URI)
        # split and rejoin because IE7/8 don't splice values of capturing regexes into split's return array
        [cssName, colonSplitCSSValues...] = style.split(":")
        @setStyle cssName, colonSplitCSSValues.join(":")
      return

    if value instanceof Batman.Hash
      @bindCollection(value)
    else
      if value instanceof Batman.Object
        value = value.toJSON()
      @resetStyles()
      for own key of value
        @bindSingleAttribute key, "#{@keyPath}.#{key}"
    return

  handleArrayChanged: (array) =>
    # Only hashes are bound to, so iterate over their keys and bind each specific attribute to the hash's value at that key.
    @collection.forEach (key, value) =>
      @bindSingleAttribute(key, "#{@keyPath}.#{key}")

  bindSingleAttribute: (attr, keyPath) ->
    definition = new Batman.DOM.AttrReaderBindingDefinition(@node, attr, keyPath, @renderContext, @renderer)
    @styleBindings[attr] = new Batman.DOM.StyleBinding.SingleStyleBinding(definition, this)

  setStyle: (key, value) =>
    key = Batman.helpers.camelize(key.trim(), true)
    unless @oldStyles[key]?
      @oldStyles[key] = @node.style[key] || ""

    value = value.trim() if value?.trim
    value ?= ""
    @node.style[key] = value

  resetStyles: ->
    @setStyle(cssName, cssValue) for own cssName, cssValue of @oldStyles
    return

  resetBindings: ->
    for attribute, binding of @styleBindings
      binding._fireDataChange ''
      binding.die()
    @styleBindings = {}

  unbindCollection: ->
    @resetBindings()
    super

  class @SingleStyleBinding extends Batman.DOM.AbstractAttributeBinding
    onlyObserve: Batman.BindingDefinitionOnlyObserve.Data
    isTwoWay: -> false

    constructor: (definition, @parent) ->
      super(definition)

    dataChange: (value) ->
      @parent.setStyle(@attributeName, value)
