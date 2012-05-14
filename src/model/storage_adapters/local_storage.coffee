#= require ./storage_adapter

class Batman.LocalStorage extends Batman.StorageAdapter
  constructor: ->
    return null if typeof window.localStorage is 'undefined'
    super
    @storage = localStorage

  storageRegExpForRecord: (record) -> new RegExp("^#{@storageKey(record)}(\\d+)$")

  nextIdForRecord: (record) ->
    re = @storageRegExpForRecord(record)
    nextId = 1
    @_forAllStorageEntries (k, v) ->
      if matches = re.exec(k)
        nextId = Math.max(nextId, parseInt(matches[1], 10) + 1)
    nextId

  _forAllStorageEntries: (iterator) ->
    for i in [0...@storage.length]
      key = @storage.key(i)
      iterator.call(@, key, @storage.getItem(key))
    true

  _storageEntriesMatching: (constructor, options) ->
    re = @storageRegExpForRecord(constructor.prototype)
    records = []
    @_forAllStorageEntries (storageKey, storageString) ->
      if keyMatches = re.exec(storageKey)
        data = @_jsonToAttributes(storageString)
        data[constructor.primaryKey] = keyMatches[1]
        records.push data if @_dataMatches(options, data)
    records

  _dataMatches: (conditions, data) ->
    match = true
    for k, v of conditions
      if data[k] != v
        match = false
        break
    match

  @::before 'read', 'create', 'update', 'destroy', @skipIfError (env, next) ->
    if env.action == 'create'
      env.id = env.subject.get('id') || env.subject.set('id', @nextIdForRecord(env.subject))
    else
      env.id = env.subject.get('id')

    unless env.id?
      env.error = new @constructor.StorageError("Couldn't get/set record primary key on #{env.action}!")
    else
      env.key = @storageKey(env.subject) + env.id

    next()

  @::before 'create', 'update', @skipIfError (env, next) ->
    env.recordAttributes = JSON.stringify(env.subject)
    next()

  @::after 'read', @skipIfError (env, next) ->
    if typeof env.recordAttributes is 'string'
      try
        env.recordAttributes = @_jsonToAttributes(env.recordAttributes)
      catch error
        env.error = error
        return next()
    env.subject._withoutDirtyTracking -> @fromJSON env.recordAttributes
    next()

  @::after 'read', 'create', 'update', 'destroy', @skipIfError (env, next) ->
    env.result = env.subject
    next()

  @::after 'readAll', @skipIfError (env, next) ->
    env.result = env.records = for recordAttributes in env.recordsAttributes
      @getRecordFromData(recordAttributes, env.subject)
    next()

  read: @skipIfError (env, next) ->
    env.recordAttributes = @storage.getItem(env.key)
    if !env.recordAttributes
      env.error = new @constructor.NotFoundError()
    next()

  create: @skipIfError ({key, recordAttributes}, next) ->
    if @storage.getItem(key)
      arguments[0].error = new @constructor.RecordExistsError
    else
      @storage.setItem(key, recordAttributes)
    next()

  update: @skipIfError ({key, recordAttributes}, next) ->
    @storage.setItem(key, recordAttributes)
    next()

  destroy: @skipIfError ({key}, next) ->
    @storage.removeItem(key)
    next()

  readAll: @skipIfError (env, next) ->
    try
      arguments[0].recordsAttributes = @_storageEntriesMatching(env.subject, env.options.data)
    catch error
      arguments[0].error = error
    next()
