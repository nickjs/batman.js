oldSend = Batman.Request::send
oldFile = Batman.container.File

QUnit.module 'Batman.Request',
  setup: ->
    @sendSpy = createSpy()
    Batman.Request::send = @sendSpy
    Batman.container.File = class File
    Batman.Request.set('pendingRequestCount', 0)

  teardown: ->
    Batman.container.File = oldFile
    Batman.Request::send = oldSend

test 'hasFileUploads() returns false when the request data has no file uploads', ->
  req = new Batman.Request data:
    user:
      name: 'Jim'
  equal req.hasFileUploads(), false

test 'hasFileUploads() returns true when the request data has a file upload in a nested object', ->
  req = new Batman.Request data:
    user:
      avatar: new File()
  equal req.hasFileUploads(), true

test 'hasFileUploads() returns true when the request data has a file upload in a nested array', ->
  req = new Batman.Request data:
    user:
      avatars: [undefined, new File()]
  equal req.hasFileUploads(), true

test 'should not fire if not given a url', ->
  new Batman.Request
  ok !@sendSpy.called

test 'should not send if autosend is false', ->
  new Batman.Request(url: 'some/test/url', autosend: false)
  ok !@sendSpy.called

test 'should not send if autosend is false and the url changes', ->
  request = new Batman.Request(url: 'some/test/url', autosend: false)
  request.set 'url', 'another/test/url'
  ok !@sendSpy.called

test 'should request a url with default get', 2, ->
  @request = new Batman.Request
    url: 'some/test/url.html'

  req = @sendSpy.lastCallContext
  equal req.url, 'some/test/url.html'
  equal req.method, 'GET'

test 'should request a url with a different method, converting the method to uppercase', 1, ->
  @request = new Batman.Request
    url: 'B/test/url.html'
    method: 'post'

  req = @sendSpy.lastCallContext
  equal req.method, 'POST'

test 'should request a url with data', 1, ->
  new Batman.Request
    url: 'some/test/url.html'
    data:
      a: "b"
      c: 1

  req = @sendSpy.lastCallContext
  deepEqual req.data, {a: "b", c: 1}

asyncTest 'should call the success callback if the request was successful', 2, ->
  postInstantiationObserver = createSpy()
  optionsHashObserver = createSpy()
  req = new Batman.Request
    url: 'some/test/url.html'
    success: optionsHashObserver

  req.on 'success', postInstantiationObserver

  delay =>
    req = @sendSpy.lastCallContext
    req.fire 'success', 'some test data'

    delay =>
      deepEqual optionsHashObserver.lastCallArguments, ['some test data']
      deepEqual postInstantiationObserver.lastCallArguments, ['some test data']

asyncTest 'should set headers', 2, ->
  new Batman.Request
    url: 'some/test/url.html'
    headers: {'test_header': 'test-value'}

  delay =>
    req = @sendSpy.lastCallContext
    notEqual req.headers.test_header, undefined
    equal req.headers.test_header, 'test-value'

test "when pendingRequestCount > 0, requestIsPending is true", ->
  ok !Batman.Request.get('requestIsPending')
  Batman.Request.set('pendingRequestCount', 1)
  ok Batman.Request.get('requestIsPending')
  Batman.Request.set('pendingRequestCount', 0)
  ok !Batman.Request.get('requestIsPending')

test "when any request fires loading, pendingRequestCount goes up", ->
  req1 = new Batman.Request(autosend: false)
  req2 = new Batman.Request(autosend: false)

  req1.fire 'loading'
  equal Batman.Request.get('pendingRequestCount'), 1
  ok Batman.Request.get('requestIsPending')

  req2.fire 'loading'
  equal Batman.Request.get('pendingRequestCount'), 2

test "when any request fires loaded, pendingRequestCount goes down", ->
  req1 = new Batman.Request(autosend: false)
  req2 = new Batman.Request(autosend: false)

  req1.fire 'loading'
  req2.fire 'loading'
  ok Batman.Request.get('requestIsPending')
  equal Batman.Request.get('pendingRequestCount'), 2

  req1.fire 'loaded'
  equal Batman.Request.get('pendingRequestCount'), 1
  ok Batman.Request.get('requestIsPending')
  req2.fire 'loaded'
  equal Batman.Request.get('pendingRequestCount'), 0
  ok !Batman.Request.get('requestIsPending')

test 'observing requestIsPending works', ->
  displays = 0
  hides = 0
  Batman.Request.observe 'requestIsPending', (newValue, oldValue) ->
    if newValue
      displays += 1
    else
      hides += 1

  req1 = new Batman.Request(autosend: false)
  req2 = new Batman.Request(autosend: false)
  req3 = new Batman.Request(autosend: false)

  req1.fire 'loading'
  equal hides, 0
  equal displays, 1
  req1.fire 'loaded'
  equal hides, 1
  equal displays, 1

  req2.fire 'loading'
  req3.fire 'loading'
  equal hides, 1
  equal displays, 2
  req2.fire 'loaded'
  equal hides, 1
  equal displays, 2
  req3.fire 'loaded'
  equal hides, 2
  equal displays, 2

old = {}
for key in ['FormData', 'File']
  old[key] = Batman.container[key] || {}

class MockFormData extends MockClass
  constructor: ->
    super
    @appended = []
    @appends = 0
  append: (k, v) ->
    @appends++
    @appended.push [k, v]

class MockFile

QUnit.module 'Batman.Request: serializing to FormData',
  setup: ->
    Batman.container.FormData = MockFormData
    Batman.container.File = MockFile
    MockFormData.reset()

  teardown: ->
    Batman.extend Batman.container, old

test 'should serialize array data to FormData objects', ->
  object =
    foo: ["bar", "baz"]

  formData = Batman.Request.objectToFormData(object)
  deepEqual formData.appended, [["foo[]", "bar"], ["foo[]", "baz"]]

test 'should serialize simple data to FormData objects', ->
  object =
    foo: "bar"

  formData = Batman.Request.objectToFormData(object)
  deepEqual formData.appended, [["foo", "bar"]]

test 'should serialize object data to FormData objects', ->
  object =
    foo:
      bar: "baz"
      qux: "corge"

  formData = Batman.Request.objectToFormData(object)
  deepEqual formData.appended, [["foo[bar]", "baz"], ["foo[qux]", "corge"]]

test 'should serialize nested object and array data to FormData objects', ->
  object =
    foo:
      bar: ["baz", null, "qux", undefined]
    corge: [{ding: "dong"}, {walla: "walla"}, {null: null}, {undefined: undefined}]

  formData = Batman.Request.objectToFormData(object)
  deepEqual formData.appended, [
    ["foo[bar][]", "baz"]
    ["foo[bar][]", ""]
    ["foo[bar][]", "qux"]
    ["foo[bar][]", ""]
    ["corge[][ding]", "dong"]
    ["corge[][walla]", "walla"]
    ["corge[][null]", ""]
    ["corge[][undefined]", ""]
  ]

test "should serialize files without touching them into FormData objects", ->
  object =
    image: new MockFile

  formData = Batman.Request.objectToFormData(object)
  equal formData.appended[0][0], 'image'
  ok formData.appended[0][1] instanceof MockFile
