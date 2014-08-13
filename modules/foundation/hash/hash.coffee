SimpleHash = require './simple_hash'
BatmanObject = require '../object/object'
Enumerable = require '../enumerable'
Property = require '../observable/property'

{extend, forEach, objectHasKey} = require '../object_helpers'

module.exports = class Hash extends BatmanObject

  class @Metadata extends BatmanObject
    extend(@prototype, Enumerable)

    constructor: (@hash) ->

    @accessor 'length', ->
      @hash.registerAsMutableSource()
      @hash.length

    @accessor 'isEmpty', 'keys', 'toArray', (key) ->
      @hash.registerAsMutableSource()
      @hash[key]()

    forEach: -> @hash.forEach(arguments...)

  constructor: ->
    @meta = new @constructor.Metadata(this)
    SimpleHash.apply(this, arguments)
    super

  extend(@prototype, Enumerable)
  propertyClass: Property

  @defaultAccessor =
    cache: false
    get: SimpleHash::get

    set: @mutation (key, value) ->
      oldResult = SimpleHash::get.call(this, key)
      result = SimpleHash::set.call(this, key, value)

      if oldResult? and oldResult != result
        @fire('itemsWereChanged', [key], [result], [oldResult])
      else
        @fire('itemsWereAdded', [key], [result])

      result

    unset: @mutation (key) ->
      result = SimpleHash::unset.call(this, key)
      @fire('itemsWereRemoved', [key], [result]) if result?
      result

  @accessor(@defaultAccessor)

  _preventMutationEvents: (block) ->
    @prevent('change')
    @prevent('itemsWereAdded')
    @prevent('itemsWereChanged')
    @prevent('itemsWereRemoved')

    try
      block.call(this)
    finally
      @allow('change')
      @allow('itemsWereAdded')
      @allow('itemsWereChanged')
      @allow('itemsWereRemoved')

  clear: @mutation ->
    keys = @keys()
    values = (@get(key) for key in keys)
    @_preventMutationEvents -> @forEach (k) => @unset(k)
    SimpleHash::clear.call(this)

    @fire('itemsWereRemoved', keys, values)
    values

  update: @mutation (object) ->
    addedKeys = []
    addedValues = []
    changedKeys = []
    changedNewValues = []
    changedOldValues = []

    @_preventMutationEvents ->
      forEach object, (k, v) =>
        if @hasKey(k)
          changedKeys.push(k)
          changedOldValues.push(@get(k))
          changedNewValues.push(@set(k,v))
        else
          addedKeys.push(k)
          addedValues.push(@set(k,v))

    @fire('itemsWereAdded', addedKeys, addedValues) if addedKeys.length > 0
    @fire('itemsWereChanged', changedKeys, changedNewValues, changedOldValues) if changedKeys.length > 0

  replace: @mutation (object) ->
    addedKeys = []
    addedValues = []
    removedKeys = []
    removedValues = []
    changedKeys = []
    changedOldValues = []
    changedNewValues = []

    @_preventMutationEvents ->
      @forEach (k) =>
        if not objectHasKey(object, k)
          removedKeys.push(k)
          removedValues.push(@unset(k))

      forEach object, (k,v) =>
        if @hasKey(k)
          changedKeys.push(k)
          changedOldValues.push(@get(k))
          changedNewValues.push(@set(k,v))
        else
          addedKeys.push(k)
          addedValues.push(@set(k,v))

    @fire('itemsWereAdded', addedKeys, addedValues) if addedKeys.length > 0
    @fire('itemsWereChanged', changedKeys, changedNewValues, changedOldValues) if changedKeys.length > 0
    @fire('itemsWereRemoved', removedKeys, removedValues) if removedKeys.length > 0

  for k in ['equality', 'hashKeyFor', 'objectKey', 'prefixedKey', 'unprefixedKey']
    @::[k] = SimpleHash::[k]

  for k in ['hasKey', 'forEach', 'isEmpty', 'keys', 'toArray', 'merge', 'toJSON', 'toObject']
    do (k) =>
      @prototype[k] = ->
        @registerAsMutableSource()
        SimpleHash::[k].apply(this, arguments)
