QUnit.module "Batman.ModelTestCase",
  setup: ->
    @testCase = new Batman.ModelTestCase

    class @Foo extends Batman.Model
      @resourceName: 'foo'
      @validate 'title', presence: true
      @encode 'foo', 'bar'
      @encode 'baz',
        decode: false
        encode: (v) -> "!#{v}!"

    @foo = new @Foo
    @foo.set 'baz', 'baz'

test 'assertValid asserts Batman Model is valid', ->
  @foo.set('title', 'foo')
  @testCase.assertValid @foo

test 'assertNotValid asserts Batman Model is not valid', ->
  @testCase.assertNotValid @foo

test 'assertDecoders asserts full decoder list matches', ->
  @testCase.assertDecoders @Foo, 'id', 'foo', 'bar'

test 'assertEncoders asserts full encoder list matches', ->
  @testCase.assertEncoders @Foo, 'foo', 'bar', 'baz'

test 'assertEncoded asserts expected value for custom encoders', ->
  @testCase.assertEncoded @foo, 'baz', '!baz!'

test 'assertEncoded asserts function return value if expected value is a function', ->
  @testCase.assertEncoded @foo, 'baz', (baz) -> baz is '!baz!'
