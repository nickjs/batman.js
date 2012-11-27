# The RenderContext class manages the stack of contexts accessible to a view during rendering.
class Batman.RenderContext
  @deProxy: (object) -> if object? && object.isContextProxy then object.get('proxiedObject') else object
  @root: ->
    if Batman.currentApp?
      root = Batman.currentApp.get('_renderContext')
    root ?= @base

  windowWrapper: {window: Batman.container}
  constructor: (@object, @parent) ->

  findKey: (key) ->
    base = key.split('.')[0].split('|')[0].trim()
    currentNode = @
    while currentNode
      # We define the behaviour of the context stack as latching a get when the first key exists,
      # so we need to check only if the basekey exists, not if all intermediary keys do as well.
      val = Batman.get(currentNode.object, base)
      if typeof val isnt 'undefined'
        val = Batman.get(currentNode.object, key)
        return [val, currentNode.object].map(@constructor.deProxy)
      currentNode = currentNode.parent

    [Batman.get(@windowWrapper, key), @windowWrapper]

  get: (key) -> @findKey(key)[0]

  contextForKey: (key) -> @findKey(key)[1]

  # Below are the three primitives that all the `Batman.DOM` helpers are composed of.
  # `descend` takes an `object`, and optionally a `scopedKey`. It creates a new `RenderContext` leaf node
  # in the tree with either the object available on the stack or the object available at the `scopedKey`
  # on the stack.
  descend: (object, scopedKey) ->
    if scopedKey
      oldObject = object
      object = new Batman.Object()
      object[scopedKey] = oldObject
    return new @constructor(object, @)

  # `descendWithDefinition` takes a binding `definition`. It creates a new `RenderContext` leaf node
  # with the runtime value of the `keyPath` available on the stack or under the context name if given. This
  # differs from a normal `descend` in that it looks up the `key` at runtime (in the parent `RenderContext`)
  # and will correctly reflect changes if the value at the `key` changes. A normal `descend` takes a concrete
  # reference to an object which never changes.
  descendWithDefinition: (definition) ->
   proxy = new ContextProxy(definition)
   return @descend(proxy, definition.attr)

  # `chain` flattens a `RenderContext`'s path to the root.
  chain: ->
    x = []
    parent = this
    while parent
      x.push parent.object
      parent = parent.parent
    x

  # `ContextProxy` is a simple class which assists in pushing dynamic contexts onto the `RenderContext` tree.
  # This happens when a `data-context` is descended into, for each iteration in a `data-foreach`,
  # and in other specific HTML bindings like `data-formfor`. `ContextProxy`s use accessors so that if the
  # value of the object they proxy changes, the changes will be propagated to any thing observing the `ContextProxy`.
  # This is good because it allows `data-context` to take keys which will change, filtered keys, and even filters
  # which take keypath arguments. It will calculate the context to descend into when any of those keys change
  # because it preserves the property of a binding, and importantly it exposes a friendly `Batman.Object`
  # interface for the rest of the `Binding` code to work with.
  @ContextProxy = class ContextProxy extends Batman.Object
    isContextProxy: true

    # Reveal the binding's final value.
    @accessor 'proxiedObject', -> @binding.get('filteredValue')
    # Proxy all gets to the proxied object.
    @accessor
      get: (key) -> @get("proxiedObject.#{key}")
      set: (key, value) -> @set("proxiedObject.#{key}", value)
      unset: (key) -> @unset("proxiedObject.#{key}")

    constructor: (definition) ->
      @binding = new Batman.DOM.AbstractBinding(definition)

Batman.RenderContext.base = new Batman.RenderContext(Batman.RenderContext::windowWrapper)
