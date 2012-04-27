Batman.DOM.Yield = class Yield extends Batman.Object
  @yields: {}

  # Helper function for queueing any invocations until the containerNode property is present
  @queued: (fn) ->
    return (args...) ->
      if @containerNode?
        fn.apply(@, args)
      else
        handler = @observe 'containerNode', =>
          result = fn.apply(@, args)
          @forget 'containerNode', handler
          result
  @reset: -> @yields = {}
  @clearAll: ->
    yieldObject.clear() for name, yieldObject of @yields
    return
  @withName: (name) ->
    @yields[name] ||= new @({name})
    @yields[name]

  clear:   @queued -> Batman.removeOrDestroyNode(child) for child in Array::slice.call(@containerNode.childNodes)
  append:  @queued (node) -> Batman.appendChild @containerNode, node, true
  replace: @queued (node) -> @clear(); @append(node)
