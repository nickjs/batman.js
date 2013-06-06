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

test 'assertValid asserts Batman Model is valid', 1, ->
  @foo.set('title', 'foo')
  @testCase.assertValid @foo

test 'assertNotValid asserts Batman Model is not valid', 1, ->
  @testCase.assertNotValid @foo

test 'assertDecoders asserts full decoder list matches', 1, ->
  @testCase.assertDecoders @Foo, 'id', 'foo', 'bar'

test 'assertEncoders asserts full encoder list matches', 1, ->
  @testCase.assertEncoders @Foo, 'foo', 'bar', 'baz'

test 'assertEncoded asserts expected value for custom encoders', 1, ->
  @testCase.assertEncoded @foo, 'baz', '!baz!'

test 'assertEncoded asserts function return value if expected value is a function', 1, ->
  @testCase.assertEncoded @foo, 'baz', (baz) -> baz is '!baz!'
