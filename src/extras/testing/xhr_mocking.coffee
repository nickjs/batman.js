Batman.XhrMocking =
  xhrWrapper: (fn) ->
    return ->
      Batman.Request.setupMockedResponse()
      return fn.apply(this, arguments)

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

    Batman.Request.addMockedResponse method, url, =>
      @completeExpectation(id)

      params ||= {}
      params.status ||= 200
      params.response ||= {}

      return params
