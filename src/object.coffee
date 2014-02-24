#= require ./_batman
#= require ./utilities/utilities
#= require ./observable/observable
#= require ./hash/simple_hash

getAccessorObject = (base, accessor) ->
  if typeof accessor is 'function'
    accessor = {get: accessor}
  for deprecated in ['cachable', 'cacheable']
    if deprecated of accessor
      Batman.developer.warn "Property accessor option \"#{deprecated}\" is deprecated. Use \"cache\" instead."
      accessor.cache = accessor[deprecated] unless 'cache' of accessor
  accessor

promiseWrapper = (fetcher) ->
  (defaultAccessor) ->
    get: (key) ->
      return existingValue if (existingValue = defaultAccessor.get.apply(this, arguments))?
      asyncDeliver = false
      newValue = undefined
      @_batman.promises ?= {}
      @_batman.promises[key] ?= do =>
        deliver = (err, result) =>
          @set(key, result) if asyncDeliver
          newValue = result
        returnValue = fetcher.call(this, deliver, key)
        newValue = returnValue unless newValue?
        true
      asyncDeliver = true
      newValue
    cache: true

wrapSingleAccessor = (core, wrapper) ->
  wrapper = wrapper?(core) or wrapper
  for k, v of core
    wrapper[k] = v unless k of wrapper
  wrapper

ObjectFunctions =
  _defineAccessor: (keys..., accessor) ->
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
    true

  _defineWrapAccessor: (keys..., wrapper) ->
    Batman.initializeObject(this)
    if keys.length is 0
      @_defineAccessor wrapSingleAccessor(@_defineAccessor(), wrapper)
    else
      for key in keys
        @_defineAccessor key, wrapSingleAccessor(@_defineAccessor(key), wrapper)
    true

  _resetPromises: ->
    return unless @_batman.promises?
    @_resetPromise(key) for key of @_batman.promises
    return

  _resetPromise: (key) ->
    @unset(key)
    @property(key).cached = false
    delete @_batman.promises[key]
    return

# `Batman.Object` is the base class for all other Batman objects. It is not abstract.
class BatmanObject extends Object
  Batman.initializeObject(this)
  Batman.initializeObject(@prototype)

  # Make every subclass and their instances observable.
  Batman.mixin @prototype, ObjectFunctions, Batman.EventEmitter, Batman.Observable
  Batman.mixin this,       ObjectFunctions, Batman.EventEmitter, Batman.Observable

  @classMixin: -> Batman.mixin this, arguments...
  @mixin: -> @classMixin.apply @prototype, arguments
  mixin: @classMixin

  @classAccessor: @_defineAccessor
  @accessor: -> @prototype._defineAccessor(arguments...)
  accessor: @_defineAccessor

  @wrapClassAccessor: @_defineWrapAccessor
  @wrapAccessor: -> @prototype._defineWrapAccessor(arguments...)
  wrapAccessor: @_defineWrapAccessor

  @observeAll: -> @::observe.apply @prototype, arguments

  @singleton: (singletonMethodName="sharedInstance") ->
    @classAccessor singletonMethodName,
      get: -> @["_#{singletonMethodName}"] ||= new this

  @accessor '_batmanID', -> @_batmanID()

  @delegate: (properties..., options = {}) ->
    Batman.developer.warn 'delegate must include to option', @, properties if !options.to
    properties.forEach (property) =>
      @accessor property,
        get: -> @get(options.to)?.get(property)
        set: (key, value) -> @get(options.to)?.set(property, value)
        unset: -> @get(options.to)?.unset(property)

  constructor: (mixins...) ->
    @_batman = new Batman._Batman(this)
    @mixin mixins...

  counter = 0
  _batmanID: ->
    @_batman.check(this)
    @_batman.id ?= counter++
    @_batman.id

  hashKey: ->
    return if typeof @isEqual is 'function'
    @_batman.hashKey ||= "<Batman.Object #{@_batmanID()}>"

  toJSON: ->
    obj = {}
    for own key, value of @ when key not in ["_batman", "hashKey", "_batmanID"]
      obj[key] = if value?.toJSON then value.toJSON() else value
    obj

  batchAccessorChanges: (properties..., wrappedFunction) ->
    for key, i in properties
      property = properties[i] = @property(key)
      property.isBatchingChanges = true
    result = wrappedFunction.call(this)
    for property in properties
      property.isBatchingChanges = false
      property.refresh()
    result

Batman.Object = BatmanObject
