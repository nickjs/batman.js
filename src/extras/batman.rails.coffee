Batman.config.pathToHTML = '/assets/batman/html'
Batman.config.protectFromCSRF = true
Batman.config.metaNameForCSRFToken = 'csrf-token'

numericKeys = [1, 2, 3, 4, 5, 6, 7, 10, 11]
date_re = ///
  ^
  (\d{4}|[+\-]\d{6})  # 1 YYYY
  (?:-(\d{2})         # 2 MM
  (?:-(\d{2}))?)?     # 3 DD
  (?:
    T(\d{2}):         # 4 HH
    (\d{2})           # 5 mm
    (?::(\d{2})       # 6 ss
    (?:\.(\d{3}))?)?  # 7 msec
    (?:(Z)|           # 8 Z
      ([+\-])         # 9 ±
      (\d{2})         # 10 tzHH
      (?::(\d{2}))?   # 11 tzmm
    )?
  )?
  $
///

Batman.Encoders.railsDate =
  encode: (value) -> value
  decode: (value) ->
    # Thanks to https://github.com/csnover/js-iso8601 for the majority of this algorithm.
    # MIT Licensed
    if value?
      if (obj = date_re.exec(value))
        # avoid NaN timestamps caused by “undefined” values being passed to Date.UTC
        for key in numericKeys
          obj[key] = +obj[key] or 0

        # allow undefined days and months
        obj[2] = (+obj[2] || 1) - 1;
        obj[3] = +obj[3] || 1;

        # process timezone by adjusting minutes
        if obj[8] != "Z" and obj[9] != undefined
          minutesOffset = obj[10] * 60 + obj[11]
          minutesOffset = 0 - minutesOffset  if obj[9] == "+"
        else
          minutesOffset = new Date(obj[1], obj[2], obj[3], obj[4], obj[5], obj[6], obj[7]).getTimezoneOffset()
        return new Date(Date.UTC(obj[1], obj[2], obj[3], obj[4], obj[5] + minutesOffset, obj[6], obj[7]))
      else
        Batman.developer.warn "Unrecognized rails date #{value}!"
        return Date.parse(value)

RailsModelMixin =
  encodeTimestamps: (attrs...) ->
    if attrs.length == 0
      attrs = ['created_at', 'updated_at']
    @encode(attrs..., encode: false, decode: Batman.Encoders.railsDate.decode)

  _encodesNestedAttributesForKeys: []

  encodesNestedAttributesFor: (keys...)->
    @_encodesNestedAttributesForKeys = @_encodesNestedAttributesForKeys.concat(keys)

Batman.Model.encodeTimestamps = ->
  Batman.developer.warn("You must use Batman.RailsStorage to use encodeTimestamps. Use it with `@persist(Batman.RailsStorage)` in your model definition.")
  RailsModelMixin.encodeTimestamps.apply(@, arguments)

class Batman.RailsStorage extends Batman.RestStorage
  @ModelMixin: Batman.mixin({}, Batman.RestStorage.ModelMixin, RailsModelMixin)

  urlForRecord: -> @_addJsonExtension(super)
  urlForCollection: -> @_addJsonExtension(super)

  _addJsonExtension: (url) ->
    if url.indexOf('?') isnt -1 or url.substr(-5, 5) is '.json'
      return url
    url + '.json'

  _errorsFrom422Response: (response) ->
    parsedResponse = JSON.parse(response)
    if 'errors' of parsedResponse
      parsedResponse.errors
    else
      parsedResponse

  @::before 'all', (env, next) ->
    return next() if not Batman.config.protectFromCSRF

    if not Batman.config.CSRF_TOKEN?
      if tag = Batman.DOM.querySelector(document.head, "meta[name=\"#{Batman.config.metaNameForCSRFToken}\"]")
        Batman.config.CSRF_TOKEN = tag.getAttribute('content')
      else
        Batman.config.CSRF_TOKEN = null

    if token = Batman.config.CSRF_TOKEN
      headers = env.options.headers ||= {}
      headers['X-CSRF-Token'] ?= token

    next()

  @::after 'update', 'create', (env, next) ->
    record = env.subject
    {error, response} = env
    if error
      # Rails validation errors
      if error instanceof Batman.StorageAdapter.UnprocessableRecordError
        try
          validationErrors = @_errorsFrom422Response(response)
        catch extractionError
          env.error = extractionError
          return next()

        for key, errorsArray of validationErrors
          for validationError in errorsArray
            record.get('errors').add(key, validationError)

        env.result = record
        env.error = record.get('errors')
        return next()
    next()


  @::before 'create', 'update', (env, next) ->
    nestedAttributeKeys = env.subject.constructor._encodesNestedAttributesForKeys
    return next() unless nestedAttributeKeys.length

    # if not serializing as form, the data has already been stringified
    if @serializeAsForm
      data = env.options.data
    else
      data = JSON.parse(env.options.data)

    if namespace = @recordJsonNamespace(env.subject)
      recordJSON = data[namespace]
    else
      recordJSON = data

    for key in nestedAttributeKeys
      if recordJSON[key]?
        attrs = recordJSON["#{key}_attributes"] = recordJSON[key]
        delete recordJSON[key]

    if !@serializeAsForm
      env.options.data = JSON.stringify(data)

    next()

  @::after 'update', @skipIfError (env, next) ->
    for key in env.subject.constructor._encodesNestedAttributesForKeys
      association = env.subject.reflectOnAssociation(key)
      if !association?
        Batman.developer.error("No assocation was found for nested attribute #{key}")
      else if association instanceof Batman.PluralAssociation
        associationSet = env.subject.get(key)
        associationSet.forEach (object) ->
          if object.get('_destroy')
            associationSet.remove(object)
            object.constructor.get('loaded').remove(object)
      else if association instanceof Batman.SingularAssociation and env.subject.get("#{key}._destroy")
        associatedRecord = env.subject.get(key)
        if associatedRecord.isProxy
          associatedRecord = associatedRecord.get('target')
        env.subject._withoutDirtyTracking -> @set(key, null)
        association.getRelatedModel().get('loaded').remove(associatedRecord)
    next()
