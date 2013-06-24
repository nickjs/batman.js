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

    _params = [200, { "Content-Type": "application/json" }, "{}"]
    _params[0] = params["status"]   if params["status"]?
    _params[1] = params["type"]     if params["type"]?
    _params[2] = params["response"] if params["response"]?

    @server.respondWith method, url, (request) =>
      confirmExpectation()
      request.respond.apply(request, _params)

    callback?()
    @server.respond()
    confirmExpectation.verify()
