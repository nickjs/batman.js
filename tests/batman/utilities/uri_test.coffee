QUnit.module 'Batman.URI',
  setup: ->
    @complexURI = "http://james:secret@www.example.com:81/one+two/three%20four/index.html?a+phrase=this+phrase&some%20thing=this%20thing&foo&bar=#blahblah"
    @pathAndQuery = "/foo/bar?num=1"

test "constructs with a full URI string", ->
  uri = new Batman.URI(@complexURI)
  equal uri.source, @complexURI
  equal uri.protocol, 'http'
  equal uri.authority, 'james:secret@www.example.com:81'
  equal uri.userInfo, 'james:secret'
  equal uri.user, 'james'
  equal uri.password, 'secret'
  equal uri.hostname, 'www.example.com'
  equal uri.port, '81'
  equal uri.relative, '/one+two/three%20four/index.html?a+phrase=this+phrase&some%20thing=this%20thing&foo&bar=#blahblah'
  equal uri.path, '/one+two/three%20four/index.html'
  equal uri.directory, '/one+two/three%20four/'
  equal uri.file, 'index.html'
  equal uri.query, 'a+phrase=this+phrase&some%20thing=this%20thing&foo&bar='
  equal uri.hash, 'blahblah'
  deepEqual uri.queryParams(),
    'a phrase': 'this phrase'
    'some thing': 'this thing'
    foo: ''
    bar: ''

test "constructs with just a path and query", ->
  uri = new Batman.URI(@pathAndQuery)
  equal uri.source, @pathAndQuery
  equal uri.protocol, ''
  equal uri.authority, ''
  equal uri.userInfo, ''
  equal uri.user, ''
  equal uri.password, ''
  equal uri.hostname, ''
  equal uri.port, ''
  equal uri.relative, '/foo/bar?num=1'
  equal uri.path, '/foo/bar'
  equal uri.directory, '/foo/'
  equal uri.file, 'bar'
  equal uri.query, 'num=1'
  equal uri.hash, ''
  deepEqual uri.queryParams(), num: '1'

test ".paramsFromQuery(query) returns a params object from the given query string", ->
  params = Batman.URI.paramsFromQuery 'a+phrase=this+phrase&some%20thing=this%20thing&foo&bar='

  deepEqual params,
    'a phrase': 'this phrase'
    'some thing': 'this thing'
    foo: ''
    bar: ''

test ".queryFromParams(params) returns a query string for the given object", ->
  query = Batman.URI.queryFromParams
    'a phrase': 'this phrase'
    foo: ''
    bar: null
    baz: undefined

  equal query, "a+phrase=this+phrase&foo=&bar=&baz="