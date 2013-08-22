#= require ../dist/undefine_module
#= require ./solo

Batman.Request.setupMockedResponse = ->
  Batman.Request.mockedResponses = {}

Batman.Request.addMockedResponse = (method, url, callback) ->
  Batman.Request.mockedResponses["#{method}::#{url}"] ||= []
  Batman.Request.mockedResponses["#{method}::#{url}"].push(callback)

Batman.Request.fetchMockedResponse = (method, url) ->
  callbackList = Batman.Request.mockedResponses?["#{method}::#{url}"]
  return if !callbackList || callbackList.length is 0

  callback = callbackList.pop()
  return callback()

Batman.Request::send = (data) ->
  data ||= @get('data')
  @fire 'loading'

  mockedResponse = Batman.Request.fetchMockedResponse(@get('method'), @get('url'))

  return if not mockedResponse
  {status, response, beforeResponse, responseHeaders} = mockedResponse

  @mixin
    status: status || 200
    response: JSON.stringify(response)
    responseHeaders: responseHeaders || {}

  beforeResponse?(this, data)

  if @status < 400
    @fire 'success', response
  else
    @fire 'error', {response: response, status: @status, request: this}

  @fire 'loaded'

Batman.setImmediate = (fn) -> setTimeout(fn, 0)
Batman.clearImmediate = (handle) -> clearTimeout(handle)

