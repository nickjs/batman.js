QUnit.module "Batman.ParamsReplacer",
  setup: ->
    @navigator =
      redirect: createSpy()
    @params = new Batman.Hash
      foo: 'fooVal'
      bar: 'barVal'
    @replacer = new Batman.ParamsReplacer(@navigator, @params)

test "toObject() delegates to the wrapped params hash", ->
  deepEqual @replacer.toObject(), @params.toObject()

test "get(key) delegates to the wrapped params hash", ->
  equal @replacer.get('foo'), 'fooVal'

test "set(key, value) delegates to the wrapped params hash and redirects in-place", ->
  @replacer.set('foo', 'newFoo')
  equal @params.get('foo'), 'newFoo'
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [{foo: 'newFoo', bar: 'barVal'}, true]

test "unset(key) delegates to the wrapped params hash and redirects in-place", ->
  @replacer.unset('foo')
  equal @params.hasKey('foo'), false
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [{bar: 'barVal'}, true]

test "replace(params) delegates to the wrapped params hash and redirects in-place", ->
  @replacer.replace foo: 'newFoo', baz: 'bazVal'
  expected = foo: 'newFoo', baz: 'bazVal'
  deepEqual @params.toObject(), expected
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [expected, true]

test "update(params) delegates to the wrapped params hash and redirects in-place", ->
  @replacer.update foo: 'newFoo', baz: 'bazVal'
  expected = foo: 'newFoo', bar: 'barVal', baz: 'bazVal'
  deepEqual @params.toObject(), expected
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [expected, true]

test "clear() delegates to the wrapped params hash and redirects in-place", ->
  @replacer.clear()
  deepEqual @params.toObject(), {}
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [{}, true]

test "ParamsPusher subclass uses @navigator.redirect", ->
  @pusher = new Batman.ParamsPusher(@navigator, @params)
  @pusher.set('foo', 'newFoo')
  equal @navigator.redirect.callCount, 1
  deepEqual @navigator.redirect.lastCallArguments, [{foo: 'newFoo', bar: 'barVal'}]

  @pusher.unset('foo')
  equal @navigator.redirect.callCount, 2
  deepEqual @navigator.redirect.lastCallArguments, [{bar: 'barVal'}]

  @pusher.replace foo: 'newFoo', bar: 'barVal'
  equal @navigator.redirect.callCount, 3
  deepEqual @navigator.redirect.lastCallArguments, [{foo: 'newFoo', bar: 'barVal'}]

  @pusher.update foo: 'newerFoo', baz: 'bazVal'
  equal @navigator.redirect.callCount, 4
  deepEqual @navigator.redirect.lastCallArguments, [{foo: 'newerFoo', bar: 'barVal', baz: 'bazVal'}]

  @pusher.clear()
  equal @navigator.redirect.callCount, 5
  deepEqual @navigator.redirect.lastCallArguments, [{}]
