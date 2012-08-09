#= require ./lib/reqwest

Batman.Request::_parseResponseHeaders = (xhr) ->
  headers = xhr.getAllResponseHeaders().split('\n').reduce((acc, header) ->
    if matches = header.match(/([^:]*):\s*(.*)/)
      key = matches[1]
      value = matches[2]
      acc[key] = value
    acc
  , {})

Batman.Request::send = (data) ->
  data ?= @get('data')
  @fire 'loading'

  options =
    url: @get 'url'
    method: @get 'method'
    type: @get 'type'
    headers: @get 'headers'

    success: (response) =>
      @mixin
        xhr: xhr
        response: response
        status: xhr?.status
        responseHeaders: @_parseResponseHeaders(xhr)

      @fire 'success', response

    error: (xhr) =>
      @mixin
        xhr: xhr
        response: xhr.responseText || xhr.content
        status: xhr.status
        responseHeaders: @_parseResponseHeaders(xhr)

      xhr.request = @
      @fire 'error', xhr

    complete: =>
      @fire 'loaded'

  if options.method in ['PUT', 'POST']
    if @hasFileUploads()
      options.data = @constructor.objectToFormData(data)
    else
      options.contentType = @get('contentType')
      options.data = Batman.URI.queryFromParams(data)

  else
    options.data = data

  # Fires the request. Grab a reference to the xhr object so we can get the status code elsewhere.
  xhr = (reqwest options).request

prefixes = ['Webkit', 'Moz', 'O', 'ms', '']
Batman.mixins.animation =
  initialize: ->
    for prefix in prefixes
      @style["#{prefix}Transform"] = 'scale(1, 1)'
      @style.opacity = 1

      @style["#{prefix}TransitionProperty"] = "#{if prefix then '-' + prefix.toLowerCase() + '-' else ''}transform, opacity"
      @style["#{prefix}TransitionDuration"] = "0.8s, 0.55s"
      @style["#{prefix}TransformOrigin"] = "left top"
    @
  show: (addToParent) ->
    show = =>
      @style.opacity = 1
      for prefix in prefixes
        @style["#{prefix}Transform"] = 'scale(1, 1)'
      @

    if addToParent
      addToParent.append?.appendChild @
      addToParent.before?.parentNode.insertBefore @, addToParent.before

      setTimeout show, 0
    else
      show()
    @
  hide: (shouldRemove) ->
    @style.opacity = 0
    for prefix in prefixes
      @style["#{prefix}Transform"] = 'scale(0, 0)'

    setTimeout((=> @parentNode?.removeChild @), 600) if shouldRemove
    @
