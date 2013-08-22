Batman.extend Batman.DOM,
  querySelectorAll: (node, selector) ->
    jQuery(selector, node)

  querySelector: (node, selector) ->
    jQuery(selector, node)[0]

  setInnerHTML: (node, html) ->
    jQuery(node).html(html)

  destroyNode: (node) ->
    Batman.DOM.cleanupNode(node)
    jQuery(node).remove()
    return

  containsNode: (parent, child) ->
    if !child
      child = parent
      parent = document.body

    $.contains(parent, child)

  textContent: (node) ->
    jQuery(node).text()

  addEventListener: (node, eventName, callback) ->
    $(node).on(eventName, callback)

  removeEventListener: (node, eventName, callback) ->
    $(node).off(eventName, callback)

Batman.View.accessor '$node', ->
  $(@node) if @get('node')

Batman.extend Batman.Request.prototype,
  _parseResponseHeaders: (xhr) ->
    headers = xhr.getAllResponseHeaders().split('\n').reduce((acc, header) ->
      if matches = header.match(/([^:]*):\s*(.*)/)
        key = matches[1]
        value = matches[2]
        acc[key] = value
      acc
    , {})

  _prepareOptions: (data) ->
    options =
      url: @get 'url'
      type: @get 'method'
      dataType: @get 'type'
      data: data || @get 'data'
      username: @get 'username'
      password: @get 'password'
      headers: @get 'headers'
      beforeSend: =>
        @fire 'loading'

      success: (response, textStatus, xhr) =>
        @mixin
          xhr: xhr
          status: xhr.status
          response: response
          responseHeaders: @_parseResponseHeaders(xhr)
        @fire 'success', response

      error: (xhr, status, error) =>
        @mixin
          xhr: xhr
          status: xhr.status
          response: xhr.responseText
          responseHeaders: @_parseResponseHeaders(xhr)
        xhr.request = @
        @fire 'error', xhr

      complete: =>
        @fire 'loaded'

    if @get('method') in ['PUT', 'POST']

      unless @hasFileUploads()
        options.contentType = @get 'contentType'
        if typeof options.data is 'object'
          options.processData = false
          options.data = Batman.URI.queryFromParams(options.data)
      else
        options.contentType = false
        options.processData = false
        options.data = @constructor.objectToFormData(options.data)

    options

  send: (data) ->
    jQuery.ajax @_prepareOptions(data)
