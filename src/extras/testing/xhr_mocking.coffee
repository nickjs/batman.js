Batman.XhrMocking =
  xhrSetup: ->
    self = this
    @_requests = {}

    Batman.Request::send = (data) ->
      data ?= @get('data')
      @fire 'loading'

      fn = self.getRequestCb(@get('url'), @get('method'))

      return if not fn
      [status, response] = fn(data)

      if status <= 400
        @fire 'success', response
      else
        @fire 'error', {response: response, status: status}

      @fire 'loaded'

  getRequestCb: (url, method) ->
    return @_requests["#{method}::#{url}"]

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
      QUnit.ok(true, 'Expected XHR called')
      return [params.status || 200, params.response || "{}"]
