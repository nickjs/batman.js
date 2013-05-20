#= require ../object
#= require ./uri

class Batman.Request extends Batman.Object
  @objectToFormData: (data) ->
    pairForList = (key, object, first = false) ->
      if object instanceof Batman.container.File
        return [[key, object]]

      list = switch Batman.typeOf(object)
        when 'Object'
          list = for k, v of object
            pairForList((if first then k else "#{key}[#{k}]"), v)
          list.reduce((acc, list) ->
            acc.concat list
          , [])
        when 'Array'
          object.reduce((acc, element) ->
            acc.concat pairForList("#{key}[]", element)
          , [])
        else
          [[key, if object? then object else ""]]

    formData = new Batman.container.FormData()
    for [key, val] in pairForList("", data, true)
      formData.append(key, val)
    formData

  @dataHasFileUploads: dataHasFileUploads = (data) ->
    return true if File? && data instanceof File
    type = Batman.typeOf(data)
    switch type
      when 'Object'
        for k, v of data
          return true if dataHasFileUploads(v)
      when 'Array'
        for v in data
          return true if dataHasFileUploads(v)
    false

  @wrapAccessor 'method', (core) ->
    set: (k,val) -> core.set.call(@, k, val?.toUpperCase?())

  method: 'GET'
  hasFileUploads: -> dataHasFileUploads(@data)
  contentType: 'application/x-www-form-urlencoded'
  autosend: true

  constructor: (options) ->
    handlers = {}
    for k, handler of options when k in ['success', 'error', 'loading', 'loaded']
      handlers[k] = handler
      delete options[k]

    super(options)
    @on k, handler for k, handler of handlers

    if @get('url')?.length > 0
      if @autosend
        @send()
    else
      @observe 'url', (url) ->
        @send() if url?

  # `send` is implemented in the platform layer files. One of those must be required for
  # `Batman.Request` to be useful.
  send: -> Batman.developer.error "Please source a dependency file for a request implementation"
