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
  {status, response, beforeResponse} = mockedResponse

  @mixin
    status: status
    response: JSON.stringify(response)

  beforeResponse?(this)

  if status < 400
    @fire 'success', response
  else
    @fire 'error', {response: response, status: status, request: this}

  @fire 'loaded'

Batman.setImmediate = (fn) -> setTimeout(fn, 0)
Batman.clearImmediate = (handle) -> clearTimeout(handle)

