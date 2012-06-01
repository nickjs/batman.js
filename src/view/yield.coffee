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

  @withName: (name) ->
    @yields[name] ||= new @({name})
    @yields[name]

  @forEach: (f) ->
    for name, yieldObject of @yields
      f(yieldObject)
    return

  @clearAll: -> @forEach (yieldObject) -> yieldObject.clear()
  @cycleAll: -> @forEach (yieldObject) -> yieldObject.cycle()
  @clearAllStale: -> @forEach (yieldObject) -> yieldObject.clearStale()

  constructor: ->
    @cycle()

  cycle: ->
    @currentVersionNodes = []

  clear:   @queued ->
    @cycle()
    for child in (child for child in @containerNode.childNodes)
      Batman.removeOrDestroyNode(child)

  clearStale: @queued ->
    for child in (child for child in @containerNode.childNodes) when !~@currentVersionNodes.indexOf(child)
      Batman.removeOrDestroyNode(child)

  append:  @queued (node) ->
    @currentVersionNodes.push node
    Batman.appendChild @containerNode, node, true

  replace: @queued (node) ->
    @clear()
    @append(node)
