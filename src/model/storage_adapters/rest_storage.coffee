#= require ./storage_adapter

class Batman.RestStorage extends Batman.StorageAdapter
  @JSONContentType: 'application/json'
  @PostBodyContentType: 'application/x-www-form-urlencoded'

  @BaseMixin =
    request: (action, options, callback) ->
      if !callback
        callback = options
        options = {}
      options.method ||= 'GET'
      options.action = action
      @_doStorageOperation options.method.toLowerCase(), options, callback

  @ModelMixin: Batman.extend({}, @BaseMixin,
    urlNestsUnder: (keys...) ->
      parents = {}
      for key in keys
        parents[key + '_id'] = Batman.helpers.pluralize(key)

      @url = (options) ->
        childSegment = Batman.helpers.pluralize(@get('resourceName').toLowerCase())
        for key, plural of parents
          parentID = options.data[key]
          if parentID
            delete options.data[key]
            return "#{plural}/#{parentID}/#{childSegment}"
        return childSegment

      @::url = ->
        childSegment = Batman.helpers.pluralize(@constructor.get('resourceName').toLowerCase())
        for key, plural of parents
          parentID = @get('dirtyKeys').get(key)
          if parentID is undefined
            parentID = @get(key)
          if parentID
            url = "#{plural}/#{parentID}/#{childSegment}"
            break
        url ||= childSegment
        if id = @get('id')
          url += '/' + id
        url
    )

  @RecordMixin: Batman.extend({}, @BaseMixin)

  defaultRequestOptions:
    type: 'json'
  _implicitActionNames: ['create', 'read', 'update', 'destroy', 'readAll']
  serializeAsForm: true

  constructor: ->
    super
    @defaultRequestOptions = Batman.extend {}, @defaultRequestOptions

  recordJsonNamespace: (record) -> Batman.helpers.singularize(@storageKey(record))
  collectionJsonNamespace: (constructor) -> Batman.helpers.pluralize(@storageKey(constructor.prototype))

  _execWithOptions: (object, key, options) -> if typeof object[key] is 'function' then object[key](options) else object[key]
  _defaultCollectionUrl: (model) -> "/#{@storageKey(model.prototype)}"
  _addParams: (url, options) ->
    if options && options.action && !(options.action in @_implicitActionNames)
      url += '/' + options.action.toLowerCase()
    url

  urlForRecord: (record, env) ->
    if record.url
      url = @_execWithOptions(record, 'url', env.options)
    else
      url = if record.constructor.url
        @_execWithOptions(record.constructor, 'url', env.options)
      else
        @_defaultCollectionUrl(record.constructor)

      if env.action != 'create'
        if (id = record.get('id'))?
          url = url + "/" + id
        else
          throw new @constructor.StorageError("Couldn't get/set record primary key on #{env.action}!")

    url = @_addParams(url, env.options)

    @urlPrefix(record, env) + url + @urlSuffix(record, env)

  urlForCollection: (model, env) ->
    url = if model.url
      @_execWithOptions(model, 'url', env.options)
    else
      @_defaultCollectionUrl(model, env.options)

    url = @_addParams(url, env.options)

    @urlPrefix(model, env) + url + @urlSuffix(model, env)

  urlPrefix: (object, env) ->
    @_execWithOptions(object, 'urlPrefix', env.options) || ''

  urlSuffix: (object, env) ->
    @_execWithOptions(object, 'urlSuffix', env.options) || ''

  request: (env, next) ->
    options = Batman.extend env.options,
      success: (data) -> env.data = data
      error: (error) -> env.error = error
      loaded: ->
        env.response = env.request.get('response')
        next()

    env.request = new Batman.Request(options)

  perform: (key, record, options, callback) ->
    options ||= {}
    Batman.extend options, @defaultRequestOptions
    super(key, record, options, callback)

  @::before 'all', @skipIfError (env, next) ->
    try
      env.options.url = if env.subject.prototype
        @urlForCollection(env.subject, env)
      else
        @urlForRecord(env.subject, env)
    catch error
      env.error = error
    next()

  @::before 'get', 'put', 'post', 'delete', @skipIfError (env, next) ->
    env.options.method = env.action.toUpperCase()
    next()

  @::before 'create', 'update', @skipIfError (env, next) ->
    json = env.subject.toJSON()
    if namespace = @recordJsonNamespace(env.subject)
      data = {}
      data[namespace] = json
    else
      data = json

    if @serializeAsForm
      # Leave the POJO in the data for the request adapter to serialize to a body
      env.options.contentType = @constructor.PostBodyContentType
    else
      data = JSON.stringify(data)
      env.options.contentType = @constructor.JSONContentType

    env.options.data = data
    next()

  @::after 'all', @skipIfError (env, next) ->
    if !env.data?
      return next()

    if typeof env.data is 'string'
      if env.data.length > 0
        try
          json = @_jsonToAttributes(env.data)
        catch error
          env.error = error
          return next()
    else
      json = env.data

    env.json = json
    next()

  extractFromNamespace: (data, namespace) ->
    if namespace and data[namespace]?
      data[namespace]
    else
      data

  @::after 'create', 'read', 'update', @skipIfError (env, next) ->
    if env.json?
      json = @extractFromNamespace(env.json, @recordJsonNamespace(env.subject))
      env.subject._withoutDirtyTracking -> @fromJSON(json)
    env.result = env.subject
    next()

  @::after 'readAll', @skipIfError (env, next) ->
    namespace = @collectionJsonNamespace(env.subject)
    env.recordsAttributes = @extractFromNamespace(env.json, namespace)

    unless Batman.typeOf(env.recordsAttributes) is 'Array'
      namespace = @recordJsonNamespace(env.subject.prototype)
      env.recordsAttributes = [@extractFromNamespace(env.json, namespace)]

    env.result = env.records = for jsonRecordAttributes in env.recordsAttributes
      @getRecordFromData(jsonRecordAttributes, env.subject)
    next()

  @::after 'get', 'put', 'post', 'delete', @skipIfError (env, next) ->
    json = env.json
    namespace = if env.subject.prototype
      @collectionJsonNamespace(env.subject)
    else
      @recordJsonNamespace(env.subject)
    env.result = if namespace && env.json[namespace]?
      env.json[namespace]
    else
      env.json
    next()

  @HTTPMethods =
    create: 'POST'
    update: 'PUT'
    read: 'GET'
    readAll: 'GET'
    destroy: 'DELETE'

  for key in ['create', 'read', 'update', 'destroy', 'readAll', 'get', 'post', 'put', 'delete']
    do (key) =>
      @::[key] = @skipIfError (env, next) ->
        env.options.method ||= @constructor.HTTPMethods[key]
        @request(env, next)
