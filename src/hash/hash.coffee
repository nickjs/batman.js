#= require simple_hash
#= require ../object

class Batman.Hash extends Batman.Object
  class @Metadata extends Batman.Object
    constructor: (@hash) ->
    @accessor 'length', ->
      @hash.registerAsMutableSource()
      @hash.length
    @accessor 'isEmpty', -> @hash.isEmpty()
    @accessor 'keys', -> @hash.keys()

  constructor: ->
    @meta = new @constructor.Metadata(this)
    Batman.SimpleHash.apply(@, arguments)
    super

  Batman.extend @prototype, Batman.Enumerable
  propertyClass: Batman.Property

  @defaultAccessor =
    get: Batman.SimpleHash::get
    set: @mutation (key, value) ->
      result = Batman.SimpleHash::set.call(@, key, value)
      @fire 'itemsWereAdded', key
      result
    unset: @mutation (key) ->
      result = Batman.SimpleHash::unset.call(@, key)
      @fire 'itemsWereRemoved', key if result?
      result
    cache: false

  @accessor @defaultAccessor

  _preventMutationEvents: (block) ->
    @prevent 'change'
    @prevent 'itemsWereAdded'
    @prevent 'itemsWereRemoved'
    try
      block.call(this)
    finally
      @allow 'change'
      @allow 'itemsWereAdded'
      @allow 'itemsWereRemoved'
  clear: @mutation ->
    keys = @keys()
    @_preventMutationEvents -> @forEach (k) => @unset(k)
    result = Batman.SimpleHash::clear.call(@)
    @fire 'itemsWereRemoved', keys...
    result
  update: @mutation (object) ->
    addedKeys = []
    @_preventMutationEvents ->
      Batman.forEach object, (k,v) =>
        addedKeys.push(k) unless @hasKey(k)
        @set(k,v)
    @fire('itemsWereAdded', addedKeys...) if addedKeys.length > 0
  replace: @mutation (object) ->
    addedKeys = []
    removedKeys = []
    @_preventMutationEvents ->
      @forEach (k, _) =>
        unless Batman.objectHasKey(object, k)
          @unset(k)
          removedKeys.push(k)
      Batman.forEach object, (k,v) =>
        addedKeys.push(k) unless @hasKey(k)
        @set(k,v)
    @fire('itemsWereAdded', addedKeys...) if addedKeys.length > 0
    @fire('itemsWereRemoved', removedKeys...) if removedKeys.length > 0

  for k in ['equality', 'hashKeyFor', 'objectKey', 'prefixedKey', 'unprefixedKey']
    @::[k] = Batman.SimpleHash::[k]

  for k in ['hasKey', 'forEach', 'isEmpty', 'keys', 'merge', 'toJSON', 'toObject']
    do (k) =>
      @prototype[k] = ->
        @registerAsMutableSource()
        Batman.SimpleHash::[k].apply(@, arguments)
