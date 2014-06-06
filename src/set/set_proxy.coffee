#= require ../object
#= require ./set

class Batman.SetProxy extends Batman.Object
  constructor: (@base) ->
    super()
    @length = @base.length

    if @base.isCollectionEventEmitter
      @isCollectionEventEmitter = true

      @_setObserver = new Batman.SetObserver(@base)
      @_setObserver.on 'itemsWereAdded', @_handleItemsAdded.bind(this)
      @_setObserver.on 'itemsWereRemoved', @_handleItemsRemoved.bind(this)
      @startObserving()

  Batman.extend @prototype, Batman.Enumerable

  startObserving: -> @_setObserver?.startObserving()
  stopObserving: -> @_setObserver?.stopObserving()

  _handleItemsAdded: (items, indexes) ->
    @set('length', @base.length)
    @fire('itemsWereAdded', items, indexes)

  _handleItemsRemoved: (items, indexes) ->
    @set('length', @base.length)
    @fire('itemsWereRemoved', items, indexes)

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

  for k in ['add', 'addArray', 'insert', 'insertWithIndexes', 'remove', 'removeWithIndexes', 'at', 'find', 'clear', 'has', 'merge', 'toArray', 'isEmpty', 'indexedBy', 'indexedByUnique', 'sortedBy', 'mappedTo']
    do (k) =>
      @::[k] = -> @base[k].apply(@base, arguments)

  @accessor 'length',
    get: ->
      @registerAsMutableSource()
      @length
    set: (_, v) -> @length = v
