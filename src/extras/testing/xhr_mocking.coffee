Batman.XhrMocking =
  xhrSetup: ->
    @server = sinon.sandbox.useFakeServer()

  assertGET: (url, params, callback) ->
    @_assertXHR('GET', url, params, callback)

  assertPOST: (url, params, callback) ->
    @_assertXHR('POST', url, params, callback)

  assertPUT: (url, params, callback) ->
    @_assertXHR('PUT', url, params, callback)

  assertDELETE: (url, params, callback) ->
    @_assertXHR('DELETE', url, params, callback)

  _assertXHR: (method, url, params, callback) ->
    confirmExpectation = sinon.mock()

    paramsArray = [
      params.status || 200,
      params.type || {'Content-Type': 'application/json'},
      params.response || "{}"
    ]

    @server.respondWith method, url, (request) =>
      confirmExpectation()
      request.respond.apply(request, paramsArray)

    callback?()
    @server.respond()
    confirmExpectation.verify()
