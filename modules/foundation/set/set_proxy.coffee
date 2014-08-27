BatmanObject = require '../object/object'
SetObserver = require './set_observer'
Set = require './set'
Enumerable = require '../enumerable'

{extend} = require '../object_helpers'

module.exports = class SetProxy extends BatmanObject
  constructor: (@base) ->
    super()
    @length = @base.length

    if @base.isCollectionEventEmitter
      @isCollectionEventEmitter = true

      @_setObserver = new SetObserver(@base)
      @_setObserver.on 'itemsWereAdded', @_handleItemsAdded.bind(this)
      @_setObserver.on 'itemsWereRemoved', @_handleItemsRemoved.bind(this)
      @startObserving()

  extend(@prototype, Enumerable)

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
    , new Set()

  replace: ->
    length = @property('length')
    length.isolate()
    result = @base.replace.apply(@base, arguments)
    length.expose()
    result

  Set._applySetAccessors(@)

  for k in ['add', 'addArray', 'insert', 'insertWithIndexes', 'remove', 'removeArray', 'removeWithIndexes', 'at', 'find', 'clear', 'has', 'merge', 'toArray', 'isEmpty', 'indexedBy', 'indexedByUnique', 'sortedBy', 'mappedTo']
    do (k) =>
      @::[k] = -> @base[k].apply(@base, arguments)

  @accessor 'length',
    get: ->
      @registerAsMutableSource()
      @length
    set: (_, v) -> @length = v
