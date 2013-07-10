Batman.XhrMocking =
  xhrSetup: ->
    testCase = this

    @_requests = {}
    @_savedSend = Batman.Request::send

    Batman.Request::send = (data) ->
      data ||= @get('data')
      @fire 'loading'

      mockedResponse = testCase.fetchMockedResponse(@get('url'), @get('method'))

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

  xhrTeardown: ->
    Batman.Request::send = @_savedSend

  fetchMockedResponse: (url, method) ->
    id = "#{method}::#{url}"
    expectationCallback = @_requests[id]

    return if not expectationCallback

    delete @_requests[id]
    return expectationCallback()

  setMockedResponse: (url, method, cb) ->
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

    @setMockedResponse url, method, =>
      @completeExpectation(id)

      params ||= {}
      params.status ||= 200
      params.response ||= {}

      return params
