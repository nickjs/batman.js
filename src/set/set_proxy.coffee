#= require ../object
#= require ./set

class Batman.SetProxy extends Batman.Object
  constructor: (@base) ->
    super()
    @length = @base.length
    @base.on 'itemsWereAdded', (items...) =>
      @set 'length', @base.length
      @fire('itemsWereAdded', items...)
    @base.on 'itemsWereRemoved', (items...) =>
      @set 'length', @base.length
      @fire('itemsWereRemoved', items...)

  Batman.extend @prototype, Batman.Enumerable

  filter: (f) ->
    r = new Batman.Set()
    @reduce(((r, e) -> r.add(e) if f(e); r), r)

  replace: ->
    length = @property('length')
    length.isolate()
    result = @base.replace.apply(@, arguments)
    length.expose()
    result

  for k in ['add', 'remove', 'find', 'clear', 'has', 'merge', 'toArray', 'isEmpty', 'indexedBy', 'indexedByUnique', 'sortedBy']
    do (k) =>
      @::[k] = -> @base[k](arguments...)

  Batman.Set._applySetAccessors(@)

  @accessor 'length',
    get: ->
      @registerAsMutableSource()
      @length
    set: (_, v) -> @length = v
