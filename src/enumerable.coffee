Batman.Enumerable =
  isEnumerable: true

  map: (f, ctx = Batman.container) ->
    result = []
    @forEach -> result.push f.apply(ctx, arguments)
    result

  mapToProperty: (key) ->
    result = []
    @forEach (item) -> result.push Batman.get(item, key)
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
    index = 0
    initialValuePassed = accumulator?

    @forEach (element, value) =>
      if !initialValuePassed
        accumulator = element
        initialValuePassed = true
        return

      accumulator = f(accumulator, element, value, index, self)
      index++

    accumulator

  filter: (f) ->
    result = new @constructor
    if result.add
      wrap = (result, element, value) =>
        result.add(element) if f(element, value, this)
        result
    else if result.set
      wrap = (result, element, value) =>
        result.set(element, value) if f(element, value, this)
        result
    else
      result = [] unless result.push
      wrap = (result, element, value) =>
        result.push(element) if f(element, value, this)
        result

    @reduce wrap, result

  count: (f, ctx = Batman.container) ->
    return @length unless f
    count = 0
    @forEach (element, value) => count++ if f.call(ctx, element, value, this)
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
