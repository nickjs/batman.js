Batman.Enumerable =
  isEnumerable: true

  map: (f, ctx = Batman.container) ->
    result = []
    @forEach -> result.push f.apply(ctx, arguments)
    result

  mapToProperty: (key) ->
    result = []
    @forEach (item) -> result.push item.get(key)
    result

  every: (f, ctx = Batman.container) ->
    result = true
    @forEach -> result = result && f.apply(ctx, arguments)
    result

  some: (f, ctx = Batman.container) ->
    result = false
    @forEach -> result = result || f.apply(ctx, arguments)
    result

  reduce: (f, accumulator) ->
    count = 0
    self = @
    if accumulator?
      initialValuePassed = true
    else
      initialValuePassed = false

    @forEach ->
      if !initialValuePassed
        accumulator = arguments[0]
        initialValuePassed = true
        return

      accumulator = f(accumulator, arguments..., count, self)

    accumulator

  filter: (f) ->
    result = new @constructor
    if result.add
      wrap = (result, element) -> result.add(element) if f(element); result
    else if result.set
      wrap = (result, key, value) -> result.set(key, value) if f(key, value); result
    else
      result = [] unless result.push
      wrap = (result, element) -> result.push(element) if f(element); result
    @reduce wrap, result

  count: (f, ctx = Batman.container) ->
    return @length unless f
    count = 0
    @forEach (keyOrValue, value) -> count++ if f.apply(ctx, keyOrValue, value, this)
    count

  inGroupsOf: (groupSize) ->
    result = []
    current = false
    i = 0
    @forEach (element) ->
      if i++ % groupSize == 0
        current = []
        result.push current
      current.push element
    result
