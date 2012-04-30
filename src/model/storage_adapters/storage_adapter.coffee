#= require ../../object

class Batman.StorageAdapter extends Batman.Object

  class @StorageError extends Error
    name: "StorageError"
    constructor: (message) ->
      super
      @message = message

  class @RecordExistsError extends @StorageError
    name: 'RecordExistsError'
    constructor: (message) ->
      super(message || "Can't create this record because it already exists in the store!")

  class @NotFoundError extends @StorageError
    name: 'NotFoundError'
    constructor: (message) ->
      super(message || "Record couldn't be found in storage!")

  constructor: (model) ->
    super(model: model)
    constructor = @constructor
    Batman.extend model, constructor.ModelMixin if constructor.ModelMixin
    Batman.extend model.prototype, constructor.RecordMixin if constructor.RecordMixin

  isStorageAdapter: true

  storageKey: (record) ->
    model = record?.constructor || @model
    model.get('storageKey') || Batman.helpers.pluralize(Batman.helpers.underscore(Batman.functionName(model)))

  getRecordFromData: (attributes, constructor = @model) ->
    record = new constructor()
    record.fromJSON(attributes)
    record

  @skipIfError: (f) ->
    return (env, next) ->
      if env.error?
        next()
      else
        f.call(@, env, next)

  before: -> @_addFilter('before', arguments...)
  after: -> @_addFilter('after', arguments...)

  _inheritFilters: ->
    if !@_batman.check(@) || !@_batman.filters
      oldFilters = @_batman.getFirst('filters')
      @_batman.filters = {before: {}, after: {}}
      if oldFilters?
        for position, filtersByKey of oldFilters
          for key, filtersList of filtersByKey
            @_batman.filters[position][key] = filtersList.slice(0)

  _addFilter: (position, keys..., filter) ->
    @_inheritFilters()
    for key in keys
      @_batman.filters[position][key] ||= []
      @_batman.filters[position][key].push filter
    true

  runFilter: (position, action, env, callback) ->
    @_inheritFilters()
    allFilters = @_batman.filters[position].all || []
    actionFilters = @_batman.filters[position][action] || []
    env.action = action

    filters = if position == 'before'
      # Action specific filter execute first, and then the `all` filters.
      actionFilters.concat(allFilters)
    else
      # `all` filters execute first, and then the action specific filters
      allFilters.concat(actionFilters)

    next = (newEnv) =>
      env = newEnv if newEnv?
      if (nextFilter = filters.shift())?
        nextFilter.call @, env, next
      else
        callback.call @, env

    next()

  runBeforeFilter: -> @runFilter 'before', arguments...
  runAfterFilter: (action, env, callback) -> @runFilter 'after', action, env, @exportResult(callback)
  exportResult: (callback) -> (env) -> callback(env.error, env.result, env)

  _jsonToAttributes: (json) -> JSON.parse(json)

  perform: (key, subject, options, callback) ->
    options ||= {}
    env = {options, subject}

    next = (newEnv) =>
      env = newEnv if newEnv?
      @runAfterFilter key, env, callback

    @runBeforeFilter key, env, (env) ->
      @[key](env, next)
