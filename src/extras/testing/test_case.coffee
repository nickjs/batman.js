class Batman.TestCase extends Batman.Object
  @mixin Batman.XhrMocking

  class @Test
    constructor: (@name, @expected, @testFunction) ->

  @test: (name, expected, testFunction) ->
    if typeof expected is 'function'
      testFunction = expected
      expected = null

    @tests ||= []
    @tests.push new @Test(name, expected, testFunction)

  runTests: (context) ->
    QUnit.module.call context, @constructor.name,
      setup: @setup.bind(this)
      teardown: @teardown.bind(this)

    for desc, test of @constructor.tests
      QUnit.test(test.name, test.expected, sinon.test(test.testFunction).bind(this))

  setup: ->

  teardown: ->

  continue: ->
    QUnit.start()

  wait: ->
    QUnit.stop()

  assert: (assertion, message = 'was not true') ->
    QUnit.ok assertion, message

  assertEqual: (expected, actual, message) ->
    QUnit.deepEqual actual, expected, message

  assertNotEqual: (expected, actual, message) ->
    QUnit.notDeepEqual actual, expected, message

  assertMatch: (expected, actual, message) ->
    QUnit.ok expected.test(actual), message

  assertNoMatch: (expected, actual, message) ->
    QUnit.ok !expected.test(actual), message

  assertDifference: (expressions, difference = 1, message, callback) ->
    if Batman.typeOf(expressions) != 'Array'
      expressions = [expressions]

    if arguments.length is 2
      callback = difference
      difference = 1
    else if arguments.length is 3
      callback = message
      message = null

    before = expressions.map (expression) ->
      eval expression

    callback()

    for e, i in expressions
      error = "#{e} didn't change by #{difference}"
      error = "#{message}.\n#{error}" if message
      @assertEqual before[i] + difference, eval(e), error

  assertNoDifference: (expressions, message, callback) ->
    if arguments.length is 2
      callback = message
      message = null

    @assertDifference expressions, 0, message, callback

  assertRaises: (expected, callback, message) ->
    QUnit.raises callback, expected, message

