#= require abstract_collection_binding

class Batman.DOM.StyleBinding extends Batman.DOM.AbstractCollectionBinding

  class @SingleStyleBinding extends Batman.DOM.AbstractAttributeBinding
    constructor: (args..., @parent) ->
      super(args...)
    dataChange: (value) -> @parent.setStyle(@attributeName, value)

  constructor: ->
    @oldStyles = {}
    super

  dataChange: (value) ->
    unless value
      @reapplyOldStyles()
      return

    @unbindCollection()

    if typeof value is 'string'
      @reapplyOldStyles()
      for style in value.split(';')
        # handle a case when css value contains colons itself (absolute URI)
        # split and rejoin because IE7/8 don't splice values of capturing regexes into split's return array
        [cssName, colonSplitCSSValues...] = style.split(":")
        @setStyle cssName, colonSplitCSSValues.join(":")
      return

    if value instanceof Batman.Hash
      if @bindCollection(value)
        value.forEach (key, value) => @setStyle key, value
    else if value instanceof Object
      @reapplyOldStyles()
      for own key, keyValue of value
        # Check whether the value is an existing keypath, and if so bind this attribute to it
        if keypathValue = @renderContext.get(keyValue)
          @bindSingleAttribute key, keyValue
          @setStyle key, keypathValue
        else
          @setStyle key, keyValue

  handleItemsWereAdded: (newKey) => @setStyle newKey, @collection.get(newKey); return
  handleItemsWereRemoved: (oldKey) => @setStyle oldKey, ''; return

  bindSingleAttribute: (attr, keyPath) -> new @constructor.SingleStyleBinding(@node, attr, keyPath, @renderContext, @renderer, @only, @)

  setStyle: (key, value) =>
    return unless key
    key = Batman.helpers.camelize(key.trim(), true)
    @oldStyles[key] = @node.style[key]
    @node.style[key] = if value then value.trim() else ""

  reapplyOldStyles: ->
    @setStyle(cssName, cssValue) for own cssName, cssValue of @oldStyles
