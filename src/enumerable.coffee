Batman.Enumerable =
  isEnumerable: true
  map:   (f, ctx = Batman.container) -> r = []; @forEach(-> r.push f.apply(ctx, arguments)); r
  mapToProperty: (key) -> r = []; @forEach((item) -> r.push item.get(key)); r
  every: (f, ctx = Batman.container) -> r = true; @forEach(-> r = r && f.apply(ctx, arguments)); r
  some:  (f, ctx = Batman.container) -> r = false; @forEach(-> r = r || f.apply(ctx, arguments)); r
  reduce: (f, r) ->
    count = 0
    self = @
    @forEach -> if r? then r = f(r, arguments..., count, self) else r = arguments[0]
    r
  filter: (f) ->
    r = new @constructor
    if r.add
      wrap = (r, e) -> r.add(e) if f(e); r
    else if r.set
      wrap = (r, k, v) -> r.set(k, v) if f(k, v); r
    else
      r = [] unless r.push
      wrap = (r, e) -> r.push(e) if f(e); r
    @reduce wrap, r
  inGroupsOf: (n) ->
    r = []
    current = false
    i = 0
    @forEach (x) ->
      if i++ % n == 0
        current = []
        r.push current
      current.push x
    r
