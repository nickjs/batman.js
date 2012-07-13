return unless IN_NODE

{spawn} = require 'child_process'
temp    = require 'temp'
path    = require 'path'
tmpdir = temp.mkdirSync()

oldGetModule = Batman.Request::getModule

QUnit.module 'Batman.Request'
  setup: ->
    @requestSpy = createSpy().whichReturns
      on: ->
      end: ->
    Batman.Request::getModule = =>
      request: @requestSpy
  teardown: ->
    Batman.Request::getModule = oldGetModule

test 'should request a url with standard options', 1, ->
  opts =
    url: 'http://www.myserver.local:9339/some/test/url.html'
    method: 'GET'
  expected =
    path: '/some/test/url.html'
    method: 'GET'
    port: '9339'
    host: 'www.myserver.local'
  @request = new Batman.Request opts

  req = @requestSpy.lastCallArguments.shift()
  delete req['headers'] # these make deepEqual sad
  deepEqual req, expected

test 'accepts GET data as object', 1, ->
  @request = new Batman.Request
    url: '/some/test/url.html'
    data:
      foo: "bar"
  req = @requestSpy.lastCallArguments.shift()
  equal req.path, '/some/test/url.html?foo=bar'

test 'accepts GET data as string', 1, ->
  @request = new Batman.Request
    url: '/some/test/url.html'
    data: 'foo=bar'
  req = @requestSpy.lastCallArguments.shift()
  equal req.path, '/some/test/url.html?foo=bar'

QUnit.module 'Batman command line helpers'

batman = path.resolve __dirname, '..', '..', 'tools', 'batman'
console.warn batman
asyncTest "boot up", ->
  proc = spawn batman
  proc.on 'exit', (code) ->
    equal code, 0
    QUnit.start()

asyncTest "generate application", ->
  dir = temp.mkdirSync()
  cmd = "cd #{dir} && #{batman} new test"
  proc = spawn 'sh', ['-c', cmd]
  proc.on 'exit', (code) ->
    equal code, 0
    QUnit.start()

