#= require ./abstract_attribute_binding

class Batman.DOM.EventBinding extends Batman.DOM.AbstractAttributeBinding
  bindImmediately: false
  constructor: (node, eventName, key, context) ->
    super
    callback = (e) =>
      e.stopBatmanPropagation = -> e.__stopBatmanPropagation = true
      Batman.currentApp.clickEvent?(node, e)
      return if e.__stopBatmanPropagation

      @get('filteredValue')?.apply @get('callbackContext'), arguments

    if attacher = Batman.DOM.events[@attributeName]
      attacher @node, callback, context
    else
      Batman.DOM.events.other @node, @attributeName, callback, context
    @bind()

  @accessor 'callbackContext', ->
    contextKeySegments = @key.split('.')
    contextKeySegments.pop()
    if contextKeySegments.length > 0
      @get('keyContext').get(contextKeySegments.join('.'))
    else
      @get('keyContext')

  # The `unfilteredValue` is whats evaluated each time any dependents change.
  @wrapAccessor 'unfilteredValue', (core) ->
    get: ->
      if k = @get('key')
        keys = k.split('.')
        if keys.length > 1
          functionKey = keys.pop()
          keyContext = Batman.getPath(this, ['keyContext'].concat(keys))
          keyContext = Batman.RenderContext.deProxy(keyContext)
          if keyContext?
            return keyContext[functionKey]

      core.get.apply(@, arguments)
