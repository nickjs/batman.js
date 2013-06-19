Batman.XhrMocking =
  initialize: ->

  setup: ->
    #super
    @_xhrExpectations = {}
    # @test = wrappedTest

  teardown: ->
    #super

  assertGET: (url, callback) ->
    @_assertXHR('GET', url, callback)
  assertPOST: (url) ->
    @_assertXHR('POST', url, callback)
  assertPUT: (url) ->
    @_assertXHR('PUT', url, callback)
  assertDELETE: (url) ->
    @_assertXHR('DELETE', url, callback)

  assertXHR: (method, url, callback) ->
    # if url is regex
    # else is string regexp escaped
    @_xhrExpectations[url] ||= 0
    @_xhrExpectations[url]++

    @fakeServer.respondWith method, url, (request) =>
      @_xhrExpectations[url]--

    callback?()
    @fakeServer.respond()
    @_assertExpectations()

  _assertExpectations: ->
    @assertEqual(0, val, "#{key} expected, not satisfied or not expected") for key, val in @_xhrExpectations
