Batman.extend Batman.DOM,
  querySelectorAll: (node, selector) -> jQuery(selector, node)
  querySelector: (node, selector) -> jQuery(selector, node)[0]
  setInnerHTML: (node, html) ->
    childNodes = (child for child in node.childNodes)
    Batman.DOM.willRemoveNode(child) for child in childNodes
    result = jQuery(node).html(html)
    Batman.DOM.didRemoveNode(child) for child in childNodes
    result
  removeNode: (node) ->
    Batman.DOM.willRemoveNode(node)
    node.parentNode?.removeChild node
    Batman.DOM.didRemoveNode(node)
  destroyNode: (node) ->
    Batman.DOM.willDestroyNode(node)
    Batman.DOM.willRemoveNode(node)
    jQuery(node).remove()
    Batman.DOM.didRemoveNode(node)
    Batman.DOM.didDestroyNode(node)
  appendChild: (parent, child) ->
    Batman.DOM.willInsertNode(child)
    jQuery(parent).append(child)
    Batman.DOM.didInsertNode(child)
  textContent: (node) -> jQuery(node).text()

Batman.Request::_parseResponseHeaders = (xhr) ->
  headers = xhr.getAllResponseHeaders().split('\n').reduce((acc, header) ->
    if matches = header.match(/([^:]*):\s*(.*)/)
      key = matches[1]
      value = matches[2]
      acc[key] = value
    acc
  , {})

Batman.Request::_prepareOptions = (data) ->
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

Batman.Request::send = (data) ->
  jQuery.ajax @_prepareOptions(data)

Batman.mixins.animation =
  show: (addToParent) ->
    jq = $(@)
    show = ->
      jq.show 600

    if addToParent
      addToParent.append?.appendChild @
      addToParent.before?.parentNode.insertBefore @, addToParent.before

      jq.hide()
      setTimeout show, 0
    else
      show()
    @

  hide: (removeFromParent) ->
    $(@).hide 600, =>
      @parentNode?.removeChild @ if removeFromParent
      Batman.DOM.didRemoveNode(@)
    @
