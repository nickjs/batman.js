QUnit.module "Batman.TestCase",
  setup: ->
    @foo = { bar: 'bar' }
    @testCase = new Batman.TestCase

test 'setup variables should be available', 1, ->
  @testCase.assertEqual @foo.bar, 'bar'

test 'assert should return true if condition is true', 1, ->
  @testCase.assert true

test 'refute should return true if condition is false', 1, ->
  @testCase.refute false

test 'assertEqual should compare equality', 2, ->
  @testCase.assertEqual 1, 1
  @testCase.assertEqual 'foo', 'foo'

test 'assertEqual should perform a deep equal by default', 1, ->
  @testCase.assertEqual [1,2,3], [1,2,3]

test 'assertNotEqual should compare inequality', 2, ->
  @testCase.assertNotEqual 1, 2
  @testCase.assertNotEqual 'foo', 'bar'

test 'assertNotEqual should compare deep inequality by default', 1, ->
  @testCase.assertNotEqual [1,2,3], [1,2,4]

test 'assertMatch should assert a regex match in a string', 1, ->
  @testCase.assertMatch /foo/, 'foo'

test 'assertNoMatch should assert string does not contain given regex', 1, ->
  @testCase.assertNoMatch /foo/, 'bar'

test 'assertDifference should assert change before and after', ->
  Batman.Foo = 1
  @testCase.assertDifference 'Batman.Foo', ->
    Batman.Foo++

test 'assertDifference should assert specified change after callback', ->
  Batman.Foo = { count: 1 }
  @testCase.assertDifference 'Batman.Foo.count', 2, ->
    Batman.Foo.count += 2

test 'assertDifference should support multiple evals', ->
  Batman.Foo = { count: 1 }
  Batman.Bar = { count: 1 }

  @testCase.assertDifference ['Batman.Foo.count', 'Batman.Bar.count'], ->
    Batman.Foo.count++
    Batman.Bar.count++

test 'assertNoDifference should assert no change before and after', 1, ->
  Batman.Foo = { count: 1 }
  @testCase.assertNoDifference 'Batman.Foo.count', ->
    Batman.Foo.bar = 'bar'

test 'assertNoDifference should support multiple evals', ->
  Batman.Foo = { count: 1 }
  Batman.Bar = { count: 1 }
  @testCase.assertNoDifference ['Batman.Foo.count', 'Batman.Bar.count'], 2, ->
    Batman.Foo.bar = 'bar'
    Batman.Bar.foo = 'foo'

test 'assertRaises should only pass if an exception is raised', 1, ->
  @testCase.assertRaises URIError, ->
    throw new URIError

test 'wait should perform an async test and wait for continue', 1, ->
  setTimeout =>
    @testCase.assert true
    @testCase.continue()

  @testCase.wait()

test 'stubAccessor should stub the return value', ->
  class Order extends Batman.Object
    @accessor 'twenty', -> 20

  order = new Order
  @testCase.stubAccessor(order, 'twenty', -> 35)
  @testCase.assertEqual 35, order.get('twenty')
