#= require ../object
#= require ../utilities/state_machine
#= require transaction

class Batman.Model extends Batman.Object
  # Override this property to define the key which storage adapters will use to store instances of this model under.
  #  - For RestStorage, this ends up being part of the url built to store this model
  #  - For LocalStorage, this ends up being the namespace in localStorage in which JSON is stored
  @storageKey: null

  @primaryKey: 'id'
  coerceIntegerPrimaryKey: true

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
            if: optionsOrFunction.if
            unless: optionsOrFunction.unless
    return

  @classAccessor 'resourceName',
    get: ->
      if @resourceName?
        @resourceName
      else if @::resourceName?
        Batman.developer.error("Please define the resourceName property of the #{Batman.functionName(@)} on the constructor and not the prototype. (For example, `@resourceName: '#{Batman.helpers.underscore(Batman.functionName(@))}'`)") if Batman.config.minificationErrors
        @::resourceName
      else
        Batman.developer.error("Please define #{Batman.functionName(@)}.resourceName in order for your model to be minification safe. (For example, `@resourceName: '#{Batman.helpers.underscore(Batman.functionName(@))}'`)") if Batman.config.minificationErrors
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
    @_resetPromises()
    result

  @find: (id, callback) ->
    @findWithOptions(id, undefined, callback)

  @findWithOptions: (id, options = {}, callback) ->
    Batman.developer.assert callback, "Must call find with a callback!"
    @_pending ||= {}
    record = @_loadIdentity(id) || @_pending[id]
    if !record?
      record = new this
      record._withoutDirtyTracking -> @set 'id', id
      @_pending[id] = record
    record.loadWithOptions options, =>
      delete @_pending[id]
      callback.apply(@, arguments)
    return record

  @load: (options, callback) ->
    if typeof options in ['function', 'undefined']
      callback = options
      options = {}
    else
      options = { data: options }

    @loadWithOptions options, callback

  @loadWithOptions: (options, callback) ->
    @fire 'loading', options
    new Promise (fulfill, reject) =>
      @_doStorageOperation 'readAll', options, (err, records, env) =>
        if err?
          @fire 'error', err
          callback?(err, [])
          reject(err)
        else
          @fire 'loaded', records, env
          callback?(err, records, env)
          fulfill(records)

  @create: (attrs, callback) ->
    if !callback
      [attrs, callback] = [{}, attrs]
    record = new this(attrs)
    record.save(callback)
    record

  @findOrCreate: (attrs, callback) ->
    record = @_loadIdentity(attrs[@primaryKey])
    if record
      record.mixin(attrs)
      callback(undefined, record)
    else
      record = new this(attrs)
      record.save(callback)
    record

  @createFromJSON: (json) ->
    @_makeOrFindRecordFromData(json)

  @createMultipleFromJSON: (array) ->
    @_makeOrFindRecordsFromData(array)

  @_loadIdentity: (id) ->
    if @coerceIntegerPrimaryKey
      id = Batman.helpers.coerceInteger(id)
    @get('loaded.indexedByUnique.id').get(id)

  @_loadRecord: (attributes) ->
    if id = attributes[@primaryKey]
      record = @_loadIdentity(id)

    record ||= new this
    record._withoutDirtyTracking -> @fromJSON(attributes)
    record

  @_makeOrFindRecordFromData: (attributes) ->
    record = @_loadRecord(attributes)
    @_mapIdentity(record)

  @_makeOrFindRecordsFromData: (attributeSet) ->
    newRecords = for attributes in attributeSet
      @_loadRecord(attributes)

    @_mapIdentities(newRecords)
    newRecords

  @_mapIdentity: (record) ->
    if (id = record.get('id'))?
      if existing = @_loadIdentity(id)
        lifecycle = existing.get('lifecycle')
        lifecycle.load()
        existing._withoutDirtyTracking ->
          attributes = record.get('attributes')?.toObject()
          @mixin(attributes) if attributes
        lifecycle.loaded()
        record = existing
      else
        @get('loaded').add(record)
    record

  @_mapIdentities: (records) ->
    newRecords = []
    for record, index in records
      if not (id = record.get('id'))?
        continue
      else if existing = @_loadIdentity(id)
        lifecycle = existing.get('lifecycle')
        lifecycle.load()
        existing._withoutDirtyTracking ->
          attributes = record.get('attributes')?.toObject()
          @mixin(attributes) if attributes
        lifecycle.loaded()
        records[index] = existing
      else
        newRecords.push record
    @get('loaded').addArray(newRecords) if newRecords.length
    return records

  @_doStorageOperation: (operation, options, callback) ->
    Batman.developer.assert @::hasStorage(), "Can't #{operation} model #{Batman.functionName(@)} without any storage adapters!"
    adapter = @::_batman.get('storage')
    adapter.perform(operation, this, options, callback)

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

  # Add a universally accessible accessor for retrieving the primary key, regardless of which key its stored under.
  @wrapAccessor 'id', (core) ->
    get: ->
      primaryKey = @constructor.primaryKey
      if primaryKey == 'id'
        core.get.apply(@, arguments)
      else
        @get(primaryKey)
    set: (key, value) ->
      primaryKey = @constructor.primaryKey
      if @coerceIntegerPrimaryKey
        value = Batman.helpers.coerceInteger(value)
      if primaryKey == 'id'
        @_willSet(key)
        core.set.call(@, key, value)
      else
        @set(primaryKey, value)

  isNew: -> typeof @get('id') is 'undefined'
  isDirty: -> @get('lifecycle.state') == 'dirty'

  updateAttributes: (attrs) ->
    @mixin(attrs)
    @

  toString: ->
    "#{@constructor.get('resourceName')}: #{@get('id')}"

  toParam: -> @get('id')

  # `toJSON` uses the various encoders for each key to grab a storable representation of the record.
  toJSON: ->
    encoders = @_batman.get('encoders')
    return {} if !encoders or encoders.isEmpty()

    obj = {}

    # Encode each key into a new object
    encoders.forEach (key, encoder) =>
      return if !encoder.encode || (val = @get(key)) == undefined

      if (encodedVal = encoder.encode(val, key, obj, this)) != undefined
        obj[encoder.as?(key, val, obj, this) ? encoder.as] = encodedVal

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
        return if !encoder.decode

        as = encoder.as?(key, data[key], obj, this) ? encoder.as
        value = data[as]
        return if value is undefined || (value is null && @_associationForAttribute(as)?)

        obj[key] = encoder.decode(value, as, data, obj, this)

    if @constructor.primaryKey isnt 'id'
      obj.id = data[@constructor.primaryKey]

    Batman.developer.do =>
      if (!encoders) || encoders.length <= 1
        Batman.developer.warn "Warning: Model #{Batman.functionName(@constructor)} has suspiciously few decoders!"

    # Mixin the buffer object to use optimized and event-preventing sets used by `mixin`.
    @mixin obj

  hasStorage: -> @_batman.get('storage')?

  # `load` fetches the record from all sources possible
  load: (options, callback) ->
    if !callback
      [options, callback] = [{}, options]
    else
      options = { data: options }

    @loadWithOptions(options, callback)

  loadWithOptions: (options, callback) ->
    hasOptions = Object.keys(options).length != 0
    if @get('lifecycle.state') in ['destroying', 'destroyed']
      err = new Error("Can't load a destroyed record!")
      callback?(err)
      return Promise.reject(err)

    _performLoad = =>
      new Promise (fulfill, reject) =>
        @_doStorageOperation 'read', options, (err, record, env) =>
          if !err
            @get('lifecycle').loaded()
            record = @constructor._mapIdentity(record)
            record.get('errors').clear()
          else
            @get('lifecycle').error()

          if !hasOptions
            @_currentLoad = null
            @_currentLoadPromise = null

          for callback in callbackQueue
            callback(err, record, env)

          if err?
            reject(err)
          else
            fulfill(record)

>>>>>>> 96ec1db... use es6-promises polyfill

    if @get('lifecycle').load()
      callbackQueue = []
      callbackQueue.push callback if callback?
      if !hasOptions
        @_currentLoad = callbackQueue
      @_doStorageOperation 'read', options, (err, record, env) =>
        unless err
          @get('lifecycle').loaded()
          record = @constructor._mapIdentity(record)
          record.get('errors').clear()
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
        err = new Batman.StateMachine.InvalidTransitionError("Can't load while in state #{@get('lifecycle.state')}")
        callback?(err)
        return Promise.reject(err)

  # `save` persists a record to all the storage mechanisms added using `@persist`. `save` will only save
  # a model if it is valid.
  save: (options, callback) ->
    if !callback
      [options, callback] = [{}, options]

    isNew = @isNew()
    [startState, storageOperation, endState] = if isNew
      ['create', 'create', 'created']
    else
      ['save', 'update', 'saved']


    if !@get('lifecycle').startTransition(startState)
      error = new Batman.StateMachine.InvalidTransitionError("Can't save while in state #{@get('lifecycle.state')}")
      callback?(error)
      return Promise.reject(error)

    new Promise (fulfill, reject) =>
      @validate (error, errors) =>
        if error || errors.length
          @get('lifecycle').failedValidation()
          return callback?(error || errors, @)

        @fire 'validated'
        associations = @constructor._batman.get('associations')
        # Save belongsTo models immediately since we don't need this model's id
        @_withoutDirtyTracking ->
          associations?.getByType('belongsTo')?.forEach (association, label) => association.apply(this)

        payload = Batman.extend {}, options, {data: options}

        @_doStorageOperation storageOperation, payload, (err, record, env) =>
          unless err
            @get('dirtyKeys').clear()
            @get('_dirtiedKeys').clear()
            if associations
              record._withoutDirtyTracking ->
                associations.getByType('hasOne')?.forEach (association, label) -> association.apply(err, record)
                associations.getByType('hasMany')?.forEach (association, label) -> association.apply(err, record)
            if !record.isTransaction # don't let the transaction polute the true instance
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

  destroy: (options, callback) ->
    if !callback
      [options, callback] = [{}, options]

    if !@get('lifecycle').destroy()
      error = new Batman.StateMachine.InvalidTransitionError("Can't destroy while in state #{@get('lifecycle.state')}")
      callback?(error)
      return Promise.reject(error)

    new Promise (fulfill, reject) =>
      payload = Batman.mixin({}, options, {data: options})
      @_doStorageOperation 'destroy', payload, (err, record, env) =>
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
    finishedValidation = (decrementBy = 1)->
      count -= decrementBy
      if count is 0
        callback?(undefined, errors)

    for validator in validators
      if validator.if
        condition = if typeof validator.if is 'string'
          @get(validator.if)
        else
          validator.if.call(this, errors, this, key)

        if !condition
          finishedValidation(validator.keys.length)
          continue

      if validator.unless
        condition = if typeof validator.unless is 'string'
          @get(validator.unless)
        else
          validator.unless.call(this, errors, this, key)

        if condition
          finishedValidation(validator.keys.length)
          continue

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

  _associationForAttribute: (attribute) ->
    @constructor._batman.get('associations')?.get(attribute)

  _doStorageOperation: (operation, options, callback) ->
    Batman.developer.assert @hasStorage(), "Can't #{operation} model #{Batman.functionName(@constructor)} without any storage adapters!"
    adapter = @_batman.get('storage')
    adapter.perform operation, this, options, => callback(arguments...)

  _withoutDirtyTracking: (block) ->
    return block.call(@) if @_pauseDirtyTracking
    @_pauseDirtyTracking = true
    result = block.call(@)
    @_pauseDirtyTracking = false
    result


  for functionName in ['load', 'save', 'validate', 'destroy']
   @::[functionName] = Batman.Property.wrapTrackingPrevention(@::[functionName])


  reflectOnAllAssociations: (associationType) ->
    associations = @constructor._batman.get('associations')
    if associationType?
      associations?.getByType(associationType)
    else
      associations?.getAll()

  reflectOnAssociation: (associationLabel) -> @constructor._batman.get('associations')?.getByLabel(associationLabel)


  transaction: -> @_transaction([], [])

  _transaction: (visited, stack) ->
    index = visited.indexOf(this)
    return stack[index] if index != -1
    visited.push(this)
    stack.push(transaction = new @constructor)

    if hasManys = @reflectOnAllAssociations('hasMany')
      hasManys = hasManys.filter (association) -> association.options.includeInTransaction
      for label in hasManys.mapToProperty('label')
        @get(label) # load empty association sets

    attributes = @get('attributes').toObject()
    for own key, value of attributes
      if value instanceof Batman.Model && !value.isTransaction
        attributes[key] = value._transaction(visited, stack)

      else if value instanceof Batman.AssociationSet && !value.isTransaction
        newValues = new Batman.TransactionAssociationSet(value, visited, stack)
        attributes[key] = newValues

      else if Batman.typeOf(value) is 'Object'
        Batman.developer.warn "You're passing a mutable object (#{key}, #{Batman.functionName(value.constructor)}) in a #{@constructor.name} transaction:", value

    transaction._withoutDirtyTracking -> transaction.updateAttributes(attributes)
    transaction._batman.base = this

    for key, value of Batman.Transaction
      transaction[key] = value

    transaction.accessor 'isTransaction', -> @isTransaction
    transaction.accessor 'base', -> @base()
    transaction
