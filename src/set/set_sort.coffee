#= require ./set_proxy
#= require ./set_observer

class Batman.SetSort extends Batman.SetProxy
  constructor: (base, @key, order="asc") ->
    super(base)
    @descending = order.toLowerCase() is "desc"
    if @base.isObservable
      @_setObserver = new Batman.SetObserver(@base)
      @_setObserver.observedItemKeys = [@key]
      boundReIndex = => @_reIndex()
      @_setObserver.observerForItemAndKey = -> boundReIndex
      @_setObserver.on 'itemsWereAdded', boundReIndex
      @_setObserver.on 'itemsWereRemoved', boundReIndex
      @startObserving()
    @_reIndex()
  startObserving: -> @_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()
  toArray: -> @get('_storage')
  forEach: (iterator, ctx) ->
    iterator.call(ctx, e, i, this) for e, i in @get('_storage')
    return

  find: (block) ->
    @base.registerAsMutableSource()
    for item in @get('_storage')
      return item if block(item)

  merge: (other) ->
    @base.registerAsMutableSource()
    new Batman.Set(@_storage...).merge(other).sortedBy(@key, @order)

  compare: (a,b) ->
    return 0 if a is b
    return 1 if a is undefined
    return -1 if b is undefined
    return 1 if a is null
    return -1 if b is null
    return 1 if a is false
    return -1 if b is false
    return 1 if a is true
    return -1 if b is true
    if a isnt a
      if b isnt b
        return 0 # both are NaN
      else
        return 1 # a is NaN
    return -1 if b isnt b # b is NaN
    return 1 if a > b
    return -1 if a < b
    return 0
  _reIndex: ->
    newOrder = @base.toArray().sort (a,b) =>
      valueA = Batman.get(a, @key)
      if typeof valueA is 'function'
        valueA = valueA.call(a)
      valueA = valueA.valueOf() if valueA?
      valueB = Batman.get(b, @key)
      if typeof valueB is 'function'
        valueB = valueB.call(b)
      valueB = valueB.valueOf() if valueB?
      multiple = if @descending then -1 else 1
      @compare.call(@, valueA, valueB) * multiple
    @_setObserver?.startObservingItems(newOrder)
    @set('_storage', newOrder)
