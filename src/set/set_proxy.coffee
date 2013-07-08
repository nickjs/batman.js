#= require ../object
#= require ./set

class Batman.SetProxy extends Batman.Object
  constructor: (@base) ->
    super()
    @length = @base.length

    if @base.isCollectionEventEmitter
      @isCollectionEventEmitter = true

      @_setObserver = new Batman.SetObserver(@base)
      @_setObserver.on 'itemsWereAdded', @handleItemsAdded.bind(this)
      @_setObserver.on 'itemsWereRemoved', @handleItemsRemoved.bind(this)
      @startObserving()

  startObserving: -> @_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()

  handleItemsAdded: (items) ->
    @set('length', @base.length)
    @fire('itemsWereAdded', items)

  handleItemsRemoved: (items) ->
    @set('length', @base.length)
    @fire('itemsWereRemoved', items)

  Batman.extend @prototype, Batman.Enumerable

  filter: (f) ->
    @reduce (accumulator, element) ->
      accumulator.add(element) if f(element)
      accumulator
    , new Batman.Set()

  replace: ->
    length = @property('length')
    length.isolate()
    result = @base.replace.apply(@base, arguments)
    length.expose()
    result

  Batman.Set._applySetAccessors(@)

  for k in ['add', 'insert', 'remove', 'addAndRemove', 'at', 'find', 'clear', 'has', 'merge', 'toArray', 'isEmpty', 'indexedBy', 'indexedByUnique', 'sortedBy']
    do (k) =>
      @::[k] = -> @base[k].apply(@base, arguments)

  @accessor 'length',
    get: ->
      @registerAsMutableSource()
      @length
    set: (_, v) -> @length = v
