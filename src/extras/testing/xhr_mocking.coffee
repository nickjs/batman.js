Batman.XhrMocking =
  xhrSetup: ->
    self = this

    @_requests = {}
    @_savedSend = Batman.Request::send

    Batman.Request::send = (data) ->
      data ?= @get('data')
      @fire 'loading'

      fn = self.getAndRemoveRequestCb(@get('url'), @get('method'))

      return if not fn
      {status, response, before} = fn(data)

      @mixin
        status: status
        response: JSON.stringify(response)

      before?(this)

      if status <= 400
        @fire 'success', response
      else
        @fire 'error', {response: response, status: status, request: this}

      @fire 'loaded'

  xhrTeardown: ->
    Batman.Request::send = @_savedSend

  getAndRemoveRequestCb: (url, method) ->
    id = "#{method}::#{url}"
    request = @_requests[id]

    delete @_requests[id]
    return request

  setRequestCb: (url, method, cb) ->
    @_requests["#{method}::#{url}"] = cb

  assertGET: (url, params) ->
    @_assertXHR('GET', url, params)

  assertPOST: (url, params) ->
    @_assertXHR('POST', url, params)

  assertPUT: (url, params) ->
    @_assertXHR('PUT', url, params)

  assertDELETE: (url, params) ->
    @_assertXHR('DELETE', url, params)

  _assertXHR: (method, url, params) ->
    id = "#{method} to #{url}"
    @addExpectation(id)

    @setRequestCb url, method, =>
      @completeExpectation(id)

      params ||= {}
      params.status ||= 200
      params.response ||= {}

      return params
