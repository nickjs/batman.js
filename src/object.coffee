#= require_tree utilities
#= require _batman
#= require event_emitter/event_emitter
#= require observable/observable
#= require hash/simple_hash

# `Batman.Object` is the base class for all other Batman objects. It is not abstract.
class BatmanObject extends Object
  Batman.initializeObject(this)
  Batman.initializeObject(@prototype)

  # Apply mixins to this class.
  @classMixin: -> Batman.mixin @, arguments...

  # Apply mixins to instances of this class.
  @mixin: -> @classMixin.apply @prototype, arguments
  mixin: @classMixin

  counter = 0
  _objectID: ->
    @_objectID = -> c
    c = counter++

  hashKey: ->
    return if typeof @isEqual is 'function'
    @hashKey = -> key
    key = "<Batman.Object #{@_objectID()}>"

  toJSON: ->
    obj = {}
    for own key, value of @ when key not in ["_batman", "hashKey", "_objectID"]
      obj[key] = if value?.toJSON then value.toJSON() else value
    obj

  getAccessorObject = (base, accessor) ->
    if typeof accessor is 'function'
      accessor = {get: accessor}
    for deprecated in ['cachable', 'cacheable']
      if deprecated of accessor
        Batman.developer.warn "Property accessor option \"#{deprecated}\" is deprecated. Use \"cache\" instead."
        accessor.cache = accessor[deprecated] unless 'cache' of accessor
    accessor

  promiseWrapper = (fetcher) ->
    (core) ->
      get: (key) ->
        val = core.get.apply(this, arguments)
        return val if (typeof val isnt 'undefined')
        returned = false
        deliver = (err, result) =>
          @set(key, result) if returned
          val = result
        fetcher.call(this, deliver, key)
        returned = true
        val
      cache: true

  wrapSingleAccessor = (core, wrapper) ->
    wrapper = wrapper?(core) or wrapper
    for k, v of core
      wrapper[k] = v unless k of wrapper
    wrapper

  @_defineAccessor: (keys..., accessor) ->
    if not accessor?
      return Batman.Property.defaultAccessorForBase(this)
    else if keys.length is 0 and Batman.typeOf(accessor) not in ['Object', 'Function']
      return Batman.Property.accessorForBaseAndKey(this, accessor)
    else if typeof accessor.promise is 'function'
      return @_defineWrapAccessor(keys..., promiseWrapper(accessor.promise))

    Batman.initializeObject this
    # Create a default accessor if no keys have been given.
    if keys.length is 0
      # The `accessor` argument is wrapped in `getAccessorObject` which allows functions to be passed in
      # as a shortcut to {get: function}
      @_batman.defaultAccessor = getAccessorObject(this, accessor)
    else
      # Otherwise, add key accessors for each key given.
      @_batman.keyAccessors ||= new Batman.SimpleHash
      @_batman.keyAccessors.set(key, getAccessorObject(this, accessor)) for key in keys

  _defineAccessor: @_defineAccessor

  @_defineWrapAccessor: (keys..., wrapper) ->
    Batman.initializeObject(this)
    if keys.length is 0
      @_defineAccessor wrapSingleAccessor(@_defineAccessor(), wrapper)
    else
      for key in keys
        @_defineAccessor key, wrapSingleAccessor(@_defineAccessor(key), wrapper)

  _defineWrapAccessor: @_defineWrapAccessor

  @classAccessor: @_defineAccessor
  @accessor: -> @prototype._defineAccessor(arguments...)
  accessor: @_defineAccessor

  @wrapClassAccessor: @_defineWrapAccessor
  @wrapAccessor: -> @prototype._defineWrapAccessor(arguments...)
  wrapAccessor: @_defineWrapAccessor

  constructor: (mixins...) ->
    @_batman = new Batman._Batman(@)
    @mixin mixins...

  # Make every subclass and their instances observable.
  @classMixin Batman.EventEmitter, Batman.Observable
  @mixin Batman.EventEmitter, Batman.Observable

  # Observe this property on every instance of this class.
  @observeAll: -> @::observe.apply @prototype, arguments

  @singleton: (singletonMethodName="sharedInstance") ->
    @classAccessor singletonMethodName,
      get: -> @["_#{singletonMethodName}"] ||= new @

Batman.Object = BatmanObject
