#= require ../object
#= require ../utilities/state_machine

class Batman.Model extends Batman.Object
  # Override this property to define the key which storage adapters will use to store instances of this model under.
  #  - For RestStorage, this ends up being part of the url built to store this model
  #  - For LocalStorage, this ends up being the namespace in localStorage in which JSON is stored
  @storageKey: null

  @primaryKey: 'id'

  # Pick one or many mechanisms with which this model should be persisted. The mechanisms
  # can be already instantiated or just the class defining them.
  @persist: (mechanism, options...) ->
    Batman.initializeObject @prototype
    mechanism = if mechanism.isStorageAdapter then mechanism else new mechanism(@)
    Batman.mixin mechanism, options... if options.length > 0
    @::_batman.storage = mechanism
    mechanism

  @storageAdapter: ->
    Batman.initializeObject @prototype
    @::_batman.storage

  # Encoders are the tiny bits of logic which manage marshalling Batman models to and from their
  # storage representations. Encoders do things like stringifying dates and parsing them back out again,
  # pulling out nested model collections and instantiating them (and JSON.stringifying them back again),
  # and marshalling otherwise un-storable object.
  @encode: (keys..., encoderOrLastKey) ->
    Batman.initializeObject @prototype
    @::_batman.encoders ||= new Batman.SimpleHash
    encoder = {}
    switch Batman.typeOf(encoderOrLastKey)
      when 'String'
        keys.push encoderOrLastKey
      when 'Function'
        encoder.encode = encoderOrLastKey
      else
        encoder = encoderOrLastKey

    for key in keys
      encoderForKey = Batman.extend {as: key}, @defaultEncoder, encoder
      @::_batman.encoders.set key, encoderForKey
    return

  @defaultEncoder:
    encode: (x) -> x
    decode: (x) -> x

  # Attach encoders and decoders for the primary key, and update them if the primary key changes.
  @observeAndFire 'primaryKey', (newPrimaryKey, oldPrimaryKey) ->
    @encode oldPrimaryKey, {encode: false, decode: false} # Remove encoding for the previous primary key
    @encode newPrimaryKey, {encode: false, decode: @defaultEncoder.decode}

  @validate: (keys..., optionsOrFunction) ->
    Batman.initializeObject @prototype
    validators = @::_batman.validators ||= []

    if typeof optionsOrFunction is 'function'
      # Given a function, use that as the actual validator, expecting it to conform to the API
      # the built in validators do.
      validators.push
        keys: keys
        callback: optionsOrFunction
    else
      # Given options, find the validations which match the given options, and add them to the validators
      # array.
      for validatorClass in Batman.Validators
        if (matches = validatorClass.matches(optionsOrFunction))
          validators.push
            keys: keys
            validator: new validatorClass(matches)

  @classAccessor 'resourceName',
    get: ->
      if @resourceName?
        @resourceName
      else
        Batman.developer.error("Please define #{Batman.functionName(@)}.resourceName in order for your model to be minification safe.") if Batman.config.minificationErrors
        Batman.helpers.underscore(Batman.functionName(@))

  @classAccessor 'all',
    get: ->
      @_batman.check(@)
      if @::hasStorage() and !@_batman.allLoadTriggered
        @load()
        @_batman.allLoadTriggered = true
      @get('loaded')

    set: (k, v) -> @set('loaded', v)

  @classAccessor 'loaded',
    get: -> @_loaded ||= new Batman.Set
    set: (k, v) -> @_loaded = v

  @classAccessor 'first', -> @get('all').toArray()[0]
  @classAccessor 'last', -> x = @get('all').toArray(); x[x.length - 1]

  @clear: ->
    Batman.initializeObject(@)
    result = @get('loaded').clear()
    @_batman.get('associations')?.reset()
    result

  @find: (id, callback) ->
    Batman.developer.assert callback, "Must call find with a callback!"
    record = new @()
    record._withoutDirtyTracking -> @set 'id', id
    record.load callback
    return record

  @load: (options, callback) ->
    if typeof options in ['function', 'undefined']
      callback = options
      options = {}

    @fire 'loading', options
    @_doStorageOperation 'readAll', {data: options}, (err, records, env) =>
      if err?
        @fire 'error', err
        callback?(err, [])
      else
        mappedRecords = (@_mapIdentity(record) for record in records)
        @fire 'loaded', mappedRecords, env
        callback?(err, mappedRecords, env)

  @create: (attrs, callback) ->
    if !callback
      [attrs, callback] = [{}, attrs]
    obj = new this(attrs)
    obj.save(callback)
    obj

  @findOrCreate: (attrs, callback) ->
    record = new this(attrs)
    if record.isNew()
      record.save(callback)
    else
      foundRecord = @_mapIdentity(record)
      callback(undefined, foundRecord)

    record

  @createFromJSON: (json) ->
    record = new this
    record._withoutDirtyTracking -> @fromJSON(json)
    @_mapIdentity(record)

  @_mapIdentity: (record) ->
    if typeof (id = record.get('id')) == 'undefined' || id == ''
      return record
    else
      existing = @get("loaded.indexedBy.id").get(id)?.toArray()[0]
      if existing
        existing._withoutDirtyTracking ->
          @updateAttributes(record.get('attributes')?.toObject() || {})
        existing
      else
        @get('loaded').add(record)
        record

  @_doStorageOperation: (operation, options, callback) ->
    Batman.developer.assert @::hasStorage(), "Can't #{operation} model #{Batman.functionName(@constructor)} without any storage adapters!"
    adapter = @::_batman.get('storage')
    adapter.perform(operation, @, options, callback)

  for functionName in ['find', 'load', 'create']
    @[functionName] = Batman.Property.wrapTrackingPrevention(@[functionName])

  # Each model instance (each record) can be in one of many states throughout its lifetime. Since various
  # operations on the model are asynchronous, these states are used to indicate exactly what point the
  # record is at in it's lifetime, which can often be during a save or load operation.

  # Define the various states for the model to use.
  class Model.InstanceLifecycleStateMachine extends Batman.DelegatingStateMachine
    @transitions
      load:
        from: ['dirty', 'clean']
        to: 'loading'
      create:
        from: ['dirty', 'clean']
        to: 'creating'
      save:
        from: ['dirty', 'clean']
        to: 'saving'
      destroy:
        from: ['dirty', 'clean']
        to: 'destroying'
      failedValidation:
        from: ['saving', 'creating']
        to: 'dirty'
      loaded: {loading: 'clean'}
      created: {creating: 'clean'}
      saved: {saving: 'clean'}
      destroyed: {destroying: 'destroyed'}
      set:
        from: ['dirty', 'clean']
        to: 'dirty'
      error:
        from: ['saving', 'creating', 'loading', 'destroying']
        to: 'error'

  # ### Record API

  # New records can be constructed by passing either an ID or a hash of attributes (potentially
  # containing an ID) to the Model constructor. By not passing an ID, the model is marked as new.
  constructor: (idOrAttributes = {}) ->
    Batman.developer.assert  @ instanceof Batman.Object, "constructors must be called with new"

    # Find the ID from either the first argument or the attributes.
    if Batman.typeOf(idOrAttributes) is 'Object'
      super(idOrAttributes)
    else
      super()
      @set('id', idOrAttributes)

  @accessor 'lifecycle', -> @lifecycle ||= new Batman.Model.InstanceLifecycleStateMachine('clean', @)
  @accessor 'attributes', -> @attributes ||= new Batman.Hash
  @accessor 'dirtyKeys', -> @dirtyKeys ||= new Batman.Hash
  @accessor '_dirtiedKeys', -> @_dirtiedKeys ||= new Batman.SimpleSet
  @accessor 'errors', -> @errors ||= new Batman.ErrorsSet
  @accessor 'isNew', -> @isNew()
  @accessor 'isDirty', -> @isDirty()

  # Default accessor implementing the latching draft behaviour
  @accessor Model.defaultAccessor =
    get: (k) -> Batman.getPath @, ['attributes', k]
    set: (k, v) ->
      if @_willSet(k)
        @get('attributes').set(k, v)
      else
        @get(k)
    unset: (k) -> @get('attributes').unset(k)

  # Add a universally accessible accessor for retrieving the primrary key, regardless of which key its stored under.
  @wrapAccessor 'id', (core) ->
    get: ->
      primaryKey = @constructor.primaryKey
      if primaryKey == 'id'
        core.get.apply(@, arguments)
      else
        @get(primaryKey)
    set: (key, value) ->
      # naively coerce string ids into integers
      if (typeof value is "string") and (value.match(/[^0-9]/) is null) and ("#{parsedValue = parseInt(value, 10)}" is value)
        value = parsedValue

      primaryKey = @constructor.primaryKey
      if primaryKey == 'id'
        @_willSet(key)
        core.set.apply(@, arguments)
      else
        @set(primaryKey, value)

  isNew: -> typeof @get('id') is 'undefined'
  isDirty: -> @lifecycle.get('state') == 'dirty'

  updateAttributes: (attrs) ->
    @mixin(attrs)
    @

  toString: ->
    "#{@constructor.get('resourceName')}: #{@get('id')}"

  toParam: -> @get('id')

  # `toJSON` uses the various encoders for each key to grab a storable representation of the record.
  toJSON: ->
    obj = {}

    # Encode each key into a new object
    encoders = @_batman.get('encoders')
    unless !encoders or encoders.isEmpty()
      encoders.forEach (key, encoder) =>
        if encoder.encode
          val = @get key
          if typeof val isnt 'undefined'
            encodedVal = encoder.encode(val, key, obj, @)
            if typeof encodedVal isnt 'undefined'
              obj[encoder.as] = encodedVal

    obj

  # `fromJSON` uses the various decoders for each key to generate a record instance from the JSON
  # stored in whichever storage mechanism.
  fromJSON: (data) ->
    obj = {}

    encoders = @_batman.get('encoders')
    # If no decoders were specified, do the best we can to interpret the given JSON each key and just setting the values.
    if !encoders or encoders.isEmpty() or !encoders.some((key, encoder) -> encoder.decode?)
      for key, value of data
        obj[key] = value
    else
      encoders.forEach (key, encoder) =>
        if encoder.decode and typeof data[encoder.as] isnt 'undefined'
          obj[key] = encoder.decode(data[encoder.as], encoder.as, data, obj, @)

    if @constructor.primaryKey isnt 'id'
      obj.id = data[@constructor.primaryKey]

    Batman.developer.do =>
      if (!encoders) || encoders.length <= 1
        Batman.developer.warn "Warning: Model #{Batman.functionName(@constructor)} has suspiciously few decoders!"

    # Mixin the buffer object to use optimized and event-preventing sets used by `mixin`.
    @mixin obj

  hasStorage: -> @_batman.get('storage')?

  # `load` fetches the record from all sources possible
  load: (options, callback) =>
    if !callback
      [options, callback] = [{}, options]
    hasOptions = Object.keys(options).length != 0
    if @get('lifecycle.state') in ['destroying', 'destroyed']
      callback?(new Error("Can't load a destroyed record!"))
      return

    if @get('lifecycle').load()
      callbackQueue = []
      callbackQueue.push callback if callback?
      if !hasOptions
        @_currentLoad = callbackQueue
      @_doStorageOperation 'read', {data: options}, (err, record, env) =>
        unless err
          @get('lifecycle').loaded()
          record = @constructor._mapIdentity(record)
        else
          @get('lifecycle').error()
        if !hasOptions
          @_currentLoad = null
        for callback in callbackQueue
          callback(err, record, env)
        return
    else
      if @get('lifecycle.state') is 'loading' && !hasOptions
        @_currentLoad.push callback if callback?
      else
        callback?(new Batman.StateMachine.InvalidTransitionError("Can't load while in state #{@get('lifecycle.state')}"))

  # `save` persists a record to all the storage mechanisms added using `@persist`. `save` will only save
  # a model if it is valid.
  save: (options, callback) =>
    if !callback
      [options, callback] = [{}, options]

    isNew = @isNew()
    [startState, storageOperation, endState] = if isNew
      ['create', 'create', 'created']
    else
      ['save', 'update', 'saved']

    if @get('lifecycle').startTransition startState
      @validate (error, errors) =>
        if error || errors.length
          @get('lifecycle').failedValidation()
          return callback?(error || errors, @)

        associations = @constructor._batman.get('associations')
        # Save belongsTo models immediately since we don't need this model's id
        @_withoutDirtyTracking ->
          associations?.getByType('belongsTo')?.forEach (association, label) => association.apply(@)

        @_doStorageOperation storageOperation, {data: options}, (err, record, env) =>
          unless err
            @get('dirtyKeys').clear()
            @get('_dirtiedKeys').clear()
            if associations
              record._withoutDirtyTracking ->
                associations.getByType('hasOne')?.forEach (association, label) -> association.apply(err, record)
                associations.getByType('hasMany')?.forEach (association, label) -> association.apply(err, record)
            record = @constructor._mapIdentity(record)
            @get('lifecycle').startTransition endState
          else
            if err instanceof Batman.ErrorsSet
              @get('lifecycle').failedValidation()
            else
              @get('lifecycle').error()
          callback?(err, record || @, env)
    else
      callback?(new Batman.StateMachine.InvalidTransitionError("Can't save while in state #{@get('lifecycle.state')}"))

  destroy: (options, callback) =>
    if !callback
      [options, callback] = [{}, options]

    if @get('lifecycle').destroy()
      @_doStorageOperation 'destroy', {data: options}, (err, record, env) =>
        unless err
          @constructor.get('loaded').remove(@)
          @get('lifecycle').destroyed()
        else
          @get('lifecycle').error()
        callback?(err, record, env)
    else
      callback?(new Batman.StateMachine.InvalidTransitionError("Can't destroy while in state #{@get('lifecycle.state')}"))

  validate: (callback) ->
    errors = @get('errors')
    errors.clear()
    validators = @_batman.get('validators') || []

    if !validators || validators.length is 0
      callback?(undefined, errors)
      return true

    count = validators.reduce ((acc, validator) -> acc + validator.keys.length), 0
    finishedValidation = ->
      if --count == 0
        callback?(undefined, errors)

    for validator in validators
      for key in validator.keys
        args = [errors, @, key, finishedValidation]
        try
          if validator.validator
            validator.validator.validateEach.apply(validator.validator, args)
          else
            validator.callback.apply(validator, args)
        catch e
          callback?(e, errors)
    return

  associationProxy: (association) ->
    Batman.initializeObject(@)
    proxies = @_batman.associationProxies ||= {}
    proxies[association.label] ||= new association.proxyClass(association, @)
    proxies[association.label]

  _willSet: (key) ->
    return true if @_pauseDirtyTracking
    if @get('lifecycle').startTransition 'set'
      unless @get('_dirtiedKeys').has(key)
        @set "dirtyKeys.#{key}", @get(key)
        @get('_dirtiedKeys').add(key)
      true
    else
      false

  _doStorageOperation: (operation, options, callback) ->
    Batman.developer.assert @hasStorage(), "Can't #{operation} model #{Batman.functionName(@constructor)} without any storage adapters!"
    adapter = @_batman.get('storage')
    adapter.perform operation, @, options, =>
      callback(arguments...)

  _withoutDirtyTracking: (block) ->
    @_pauseDirtyTracking = true
    result = block.call(@)
    @_pauseDirtyTracking = false
    result

  for functionName in ['load', 'save', 'validate', 'destroy']
   @::[functionName] = Batman.Property.wrapTrackingPrevention(@::[functionName])
